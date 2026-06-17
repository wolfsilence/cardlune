#!/usr/bin/env python3
"""
Generate JWT for App Store Connect API authentication.
Usage: python3 generate-jwt.py <KEY_ID> <ISSUER_ID> <P8_KEY_CONTENT>
"""
import sys
import time
import jwt

def main():
    key_id = sys.argv[1]
    issuer_id = sys.argv[2]
    private_key = sys.argv[3]

    payload = {
        "iss": issuer_id,
        "iat": int(time.time()),
        "exp": int(time.time()) + 1200,  # 20 minutes
        "aud": "appstoreconnect-v1",
    }

    headers = {
        "kid": key_id,
        "alg": "ES256",
        "typ": "JWT",
    }

    token = jwt.encode(payload, private_key, algorithm="ES256", headers=headers)
    print(token)

if __name__ == "__main__":
    main()
