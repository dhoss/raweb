

CREATE TABLE messages (
messageid serial,
recipient varchar(80),
sender    varchar(80),
sent      timestamp,
priority  varchar(10),
message   text
)
