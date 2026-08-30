def _make_kontrakan(client, name="Kontrakan A"):
    return client.post("/kontrakan", json={"name": name, "address": "Jl. Test"}).json()


def test_crud_kontrakan(auth_client):
    created = auth_client.post(
        "/kontrakan", json={"name": "Melati", "address": "Jl. Mawar 5"}
    )
    assert created.status_code == 201
    kid = created.json()["id"]

    assert auth_client.get("/kontrakan").json()[0]["name"] == "Melati"

    updated = auth_client.patch(f"/kontrakan/{kid}", json={"name": "Melati 2"})
    assert updated.json()["name"] == "Melati 2"

    assert auth_client.delete(f"/kontrakan/{kid}").status_code == 204
    assert auth_client.get(f"/kontrakan/{kid}").status_code == 404


def test_unit_counts_in_summary(auth_client):
    kid = _make_kontrakan(auth_client)["id"]
    auth_client.post(f"/kontrakan/{kid}/units", json={"name": "K1", "status": "terisi"})
    auth_client.post(f"/kontrakan/{kid}/units", json={"name": "K2", "status": "kosong"})

    summary = auth_client.get("/kontrakan").json()[0]
    assert summary["unit_count"] == 2
    assert summary["occupied_count"] == 1


def test_ownership_isolation(client):
    # user 1 bikin kontrakan
    client.post(
        "/auth/register",
        json={"name": "U1", "email": "u1@example.com", "password": "password123"},
    )
    t1 = client.post(
        "/auth/login", data={"username": "u1@example.com", "password": "password123"}
    ).json()["access_token"]
    kid = client.post(
        "/kontrakan",
        json={"name": "Punya U1"},
        headers={"Authorization": f"Bearer {t1}"},
    ).json()["id"]

    # user 2 tidak boleh melihatnya
    client.post(
        "/auth/register",
        json={"name": "U2", "email": "u2@example.com", "password": "password123"},
    )
    t2 = client.post(
        "/auth/login", data={"username": "u2@example.com", "password": "password123"}
    ).json()["access_token"]
    h2 = {"Authorization": f"Bearer {t2}"}

    assert client.get("/kontrakan", headers=h2).json() == []
    assert client.get(f"/kontrakan/{kid}", headers=h2).status_code == 404
    assert client.patch(f"/kontrakan/{kid}", json={"name": "x"}, headers=h2).status_code == 404
    assert client.delete(f"/kontrakan/{kid}", headers=h2).status_code == 404


def test_tenant_archive_keeps_history(auth_client):
    kid = _make_kontrakan(auth_client)["id"]
    uid = auth_client.post(f"/kontrakan/{kid}/units", json={"name": "K1"}).json()["id"]
    tid = auth_client.post(
        f"/units/{uid}/tenants", json={"name": "Pak Joko", "due_day": 5}
    ).json()["id"]
    auth_client.post(
        f"/tenants/{tid}/payments", json={"amount": 500000, "paid_date": "2026-08-01"}
    )

    assert auth_client.post(f"/tenants/{tid}/archive").json()["is_active"] is False
    # default list menyembunyikan yang diarsipkan
    assert auth_client.get(f"/units/{uid}/tenants").json() == []
    assert len(auth_client.get(f"/units/{uid}/tenants?include_inactive=true").json()) == 1
    # riwayat pembayaran tetap ada
    assert len(auth_client.get(f"/tenants/{tid}/payments").json()) == 1
