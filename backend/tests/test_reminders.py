from datetime import date, timedelta


def _setup_unit(auth_client):
    kid = auth_client.post("/kontrakan", json={"name": "K"}).json()["id"]
    return auth_client.post(f"/kontrakan/{kid}/units", json={"name": "K1"}).json()["id"]


def test_refresh_generates_rent_and_contract_reminders(auth_client):
    unit_id = _setup_unit(auth_client)
    soon = date.today() + timedelta(days=20)
    auth_client.post(
        f"/units/{unit_id}/tenants",
        json={
            "name": "Pak Joko",
            "due_day": 15,
            "rent_amount": 800000,
            "contract_end": soon.isoformat(),
        },
    )

    r = auth_client.post("/reminders/refresh")
    assert r.status_code == 200

    types = {rem["type"] for rem in auth_client.get("/reminders").json()}
    assert "sewa_jatuh_tempo" in types
    assert "kontrak_habis" in types


def test_refresh_is_idempotent(auth_client):
    unit_id = _setup_unit(auth_client)
    auth_client.post(
        f"/units/{unit_id}/tenants", json={"name": "A", "due_day": 10}
    )
    first = auth_client.post("/reminders/refresh").json()["message"]
    count_after_first = len(auth_client.get("/reminders").json())

    auth_client.post("/reminders/refresh")
    count_after_second = len(auth_client.get("/reminders").json())

    assert count_after_first == count_after_second
    assert first.startswith("1 ") or first.startswith("0 ")


def test_manual_reminder_and_mark_done(auth_client):
    unit_id = _setup_unit(auth_client)
    r = auth_client.post(
        "/reminders",
        json={
            "unit_id": unit_id,
            "type": "maintenance",
            "due_date": (date.today() + timedelta(days=3)).isoformat(),
            "title": "Cek AC",
        },
    )
    assert r.status_code == 201
    rid = r.json()["id"]

    auth_client.patch(f"/reminders/{rid}", json={"status": "done"})
    # default list menyembunyikan yang selesai
    assert all(rem["id"] != rid for rem in auth_client.get("/reminders").json())
    assert any(
        rem["id"] == rid
        for rem in auth_client.get("/reminders?include_done=true").json()
    )


def test_dashboard_shape(auth_client):
    unit_id = _setup_unit(auth_client)
    auth_client.post(
        "/reminders",
        json={
            "unit_id": unit_id,
            "type": "utilitas",
            "due_date": date.today().isoformat(),
            "title": "Bayar listrik",
        },
    )
    d = auth_client.get("/dashboard").json()
    assert d["greeting_name"] == "Tester"
    assert d["kontrakan_count"] == 1
    assert d["active_reminder_count"] >= 1
    assert d["attention"][0]["title"] == "Bayar listrik"
