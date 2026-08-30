from datetime import date, timedelta

from app.models import Reminder
from app.models.enums import ReminderStatus, ReminderType
from app.services.reminder_engine import refresh_all_users


def _unit(client) -> int:
    kid = client.post("/kontrakan", json={"name": "K"}).json()["id"]
    return client.post(f"/kontrakan/{kid}/units", json={"name": "K1"}).json()["id"]


def _reminders(client, *, include_done: bool = False) -> list[dict]:
    q = "?include_done=true" if include_done else ""
    return client.get(f"/reminders{q}").json()


def _sewa(rems: list[dict]) -> list[dict]:
    return [r for r in rems if r["type"] == "sewa_jatuh_tempo"]


def test_tambah_penyewa_langsung_bikin_reminder_tanpa_sync(auth_client):
    unit_id = _unit(auth_client)
    auth_client.post(
        f"/units/{unit_id}/tenants", json={"name": "Joko", "due_day": 15}
    )
    # TIDAK memanggil /reminders/refresh
    assert _sewa(_reminders(auth_client))


def test_ubah_due_day_memindahkan_reminder(auth_client):
    unit_id = _unit(auth_client)
    tid = auth_client.post(
        f"/units/{unit_id}/tenants", json={"name": "Joko", "due_day": 5}
    ).json()["id"]
    assert _sewa(_reminders(auth_client))[0]["due_date"].endswith("-05")

    auth_client.patch(f"/tenants/{tid}", json={"due_day": 20})

    active = _sewa(_reminders(auth_client))
    assert active and all(r["due_date"].endswith("-20") for r in active)

    old = [
        r
        for r in _reminders(auth_client, include_done=True)
        if r["due_date"].endswith("-05")
    ]
    assert old and old[0]["status"] == "dismissed"


def test_arsip_penyewa_membersihkan_reminder_otomatis(auth_client):
    unit_id = _unit(auth_client)
    tid = auth_client.post(
        f"/units/{unit_id}/tenants",
        json={
            "name": "Joko",
            "due_day": 15,
            "contract_end": (date.today() + timedelta(days=10)).isoformat(),
        },
    ).json()["id"]
    assert len(_reminders(auth_client)) == 2  # sewa + kontrak

    auth_client.post(f"/tenants/{tid}/archive")

    assert _reminders(auth_client) == []
    assert all(
        r["status"] == "dismissed"
        for r in _reminders(auth_client, include_done=True)
    )


def test_reminder_sewa_nunggak_tidak_ikut_dibuang(auth_client, db_session):
    """Reminder yang tanggalnya sudah lewat tapi masih cocok dengan due_day
    (artinya: sewa belum dibayar) harus tetap terlihat."""
    unit_id = _unit(auth_client)
    tid = auth_client.post(
        f"/units/{unit_id}/tenants", json={"name": "Joko", "due_day": 15}
    ).json()["id"]

    overdue = date(date.today().year, date.today().month, 15) - timedelta(days=30)
    overdue = date(overdue.year, overdue.month, 15)
    db_session.add(
        Reminder(
            unit_id=unit_id,
            tenant_id=tid,
            type=ReminderType.sewa_jatuh_tempo,
            due_date=overdue,
            status=ReminderStatus.pending,
            title="Sewa jatuh tempo - K1",
        )
    )
    db_session.commit()

    auth_client.post("/reminders/refresh")

    dates = {r["due_date"] for r in _reminders(auth_client)}
    assert overdue.isoformat() in dates


def test_refresh_idempoten(auth_client):
    unit_id = _unit(auth_client)
    auth_client.post(
        f"/units/{unit_id}/tenants", json={"name": "A", "due_day": 10}
    )
    n1 = len(_reminders(auth_client))
    msg = auth_client.post("/reminders/refresh").json()["message"]
    n2 = len(_reminders(auth_client))
    assert n1 == n2
    assert msg == "0 reminder baru, 0 dibersihkan."


def test_scheduler_tidak_start_saat_test():
    from app.services import scheduler

    scheduler.start_scheduler()
    assert scheduler._scheduler is None  # SCHEDULER_ENABLED=false di conftest


def test_refresh_all_users_jalan(auth_client, db_session):
    unit_id = _unit(auth_client)
    auth_client.post(
        f"/units/{unit_id}/tenants", json={"name": "A", "due_day": 8}
    )
    result = refresh_all_users(db_session)
    assert result.created >= 0 and result.dismissed >= 0
