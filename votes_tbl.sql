DROP TABLE IF EXISTS badc_co_voting_names;

CREATE TABLE badc_co_voting_names (
       sqd_pref	       VARCHAR(10) BINARY UNIQUE,
       totalvotes      INT(3),
       votesused       INT(3)
);

DROP TABLE IF EXISTS badc_voted_names;
CREATE TABLE badc_voted_names (
       voted_hlname    VARCHAR(30) BINARY UNIQUE,
       totalbanned     INT(1),
       currentvotes    INT(1),
       sqd_vote_1       VARCHAR(30) BINARY ,
       sqd_vote_2       VARCHAR(30) BINARY ,
       sqd_vote_3       VARCHAR(30) BINARY ,
       sqd_vote_4       VARCHAR(30) BINARY ,
       sqd_vote_5       VARCHAR(30) BINARY ,
       banned_expire   INT(10)
);
