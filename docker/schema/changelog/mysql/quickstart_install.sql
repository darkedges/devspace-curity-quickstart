insert into accounts (account_id, username, password, email, phone, attributes, active, created, updated)
values
(
        '5cdab730-ad87-11eb-b96f-0242ac110008',
        'john.doe',	
        '$5$rounds=20000$lSlVng9ZCQyTL5e1$D9Fg9mA1UGhKNKyh99C/eqpHsa1afjMzi/8Od4xnp2.'	,
        'john.doe@curity.local',
        '\N'	,
        '{"name": {"givenName": "John", "familyName": "Doe"}, "emails": [{"value": "john.doe@curity.local", "primary": true}], "agreeToTerms": "on", "urn:se:curity:scim:2.0:Devices": []}',	
        1,	
        1620208245,
        1620208245
);