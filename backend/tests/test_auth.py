def test_register_and_login(client):
    r = client.post(
        "/auth/register",
        json={"name": "Budi", "email": "budi@example.com", "password": "password123"},
    )
    assert r.status_code == 201
    assert "access_token" in r.json()

    r = client.post(
        "/auth/login",
        data={"username": "budi@example.com", "password": "password123"},
    )
    assert r.status_code == 200
    token = r.json()["access_token"]

    r = client.get("/auth/me", headers={"Authorization": f"Bearer {token}"})
    assert r.status_code == 200
    assert r.json()["email"] == "budi@example.com"


def test_duplicate_email_rejected(client):
    payload = {"name": "A", "email": "dup@example.com", "password": "password123"}
    assert client.post("/auth/register", json=payload).status_code == 201
    assert client.post("/auth/register", json=payload).status_code == 409


def test_login_wrong_password(client):
    client.post(
        "/auth/register",
        json={"name": "A", "email": "x@example.com", "password": "password123"},
    )
    r = client.post(
        "/auth/login", data={"username": "x@example.com", "password": "salah"}
    )
    assert r.status_code == 401


def test_protected_route_requires_token(client):
    assert client.get("/dashboard").status_code == 401


def test_forgot_and_reset_password(client):
    client.post(
        "/auth/register",
        json={"name": "A", "email": "reset@example.com", "password": "password123"},
    )
    r = client.post("/auth/forgot-password", json={"email": "reset@example.com"})
    assert r.status_code == 200
    reset_token = r.json()["reset_token"]  # dikembalikan hanya di ENVIRONMENT=development
    assert reset_token

    r = client.post(
        "/auth/reset-password",
        json={"token": reset_token, "new_password": "passwordbaru1"},
    )
    assert r.status_code == 200

    assert (
        client.post(
            "/auth/login",
            data={"username": "reset@example.com", "password": "passwordbaru1"},
        ).status_code
        == 200
    )
