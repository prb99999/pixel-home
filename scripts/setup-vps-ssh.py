#!/usr/bin/env python3
"""Write SSH key + Host vps config from Cloud Agent secrets."""
from __future__ import annotations

import os
import re
import subprocess
import sys
from pathlib import Path


def normalize_key(raw: str) -> str:
    text = raw.strip().replace("\r\n", "\n").replace("\r", "\n")
    # Secrets UIs sometimes store literal backslash-n
    if "\\n" in text and text.count("\n") < 3:
        text = text.replace("\\n", "\n")
    match = re.match(
        r"-----BEGIN ([^-]+)-----\s*(.*?)\s*-----END \1-----",
        text,
        flags=re.S,
    )
    if not match:
        raise SystemExit("SSH_PRIVATE_KEY does not look like an OpenSSH private key")
    kind, body = match.group(1), re.sub(r"\s+", "", match.group(2))
    wrapped = "\n".join(body[i : i + 70] for i in range(0, len(body), 70))
    return f"-----BEGIN {kind}-----\n{wrapped}\n-----END {kind}-----\n"


def main() -> None:
    key = os.environ.get("SSH_PRIVATE_KEY", "")
    if not key.strip():
        raise SystemExit("SSH_PRIVATE_KEY is empty")
    user = os.environ.get("SSH_USER") or "root"
    ssh_dir = Path.home() / ".ssh"
    ssh_dir.mkdir(mode=0o700, exist_ok=True)
    key_path = ssh_dir / "id_ed25519"
    key_path.write_text(normalize_key(key), encoding="utf-8")
    key_path.chmod(0o600)
    config = (
        "Host vps\n"
        "  HostName 103.185.248.62\n"
        f"  User {user}\n"
        "  IdentityFile ~/.ssh/id_ed25519\n"
        "  IdentitiesOnly yes\n"
        "  StrictHostKeyChecking accept-new\n"
    )
    config_path = ssh_dir / "config"
    config_path.write_text(config, encoding="utf-8")
    config_path.chmod(0o600)
    subprocess.run(
        ["ssh-keygen", "-y", "-f", str(key_path)],
        check=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.PIPE,
        text=True,
    )
    print(f"SSH ready: Host vps -> 103.185.248.62 as {user}")


if __name__ == "__main__":
    try:
        main()
    except subprocess.CalledProcessError as exc:
        sys.stderr.write(exc.stderr or "ssh-keygen failed\n")
        raise SystemExit(exc.returncode)
