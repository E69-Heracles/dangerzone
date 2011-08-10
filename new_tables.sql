DROP TABLE IF EXISTS badc_air_event;
CREATE TABLE badc_air_event (
       campanya	       VARCHAR(30),
       mapa	       VARCHAR(30),
       misnum	       VARCHAR(30),
       misrep	       VARCHAR(30),
       hlkiller	       VARCHAR(30) BINARY ,
       plane_killer      VARCHAR(60),
       hlkilled	       VARCHAR(30) BINARY ,
       plane_killed      VARCHAR(60),
	 wasfriend         CHAR(3)
);

DROP TABLE IF EXISTS badc_grnd_event;
CREATE TABLE badc_grnd_event (
       campanya	       VARCHAR(30),
       mapa	       VARCHAR(30),
       misnum	       VARCHAR(30),
       misrep	       VARCHAR(30),
       hlkiller	       VARCHAR(30) BINARY ,
       plane_killer      VARCHAR(60),
       objkilled	       VARCHAR(30),
	 wasfriend         CHAR(3)
);

DROP TABLE IF EXISTS badc_host_slots;
CREATE TABLE badc_host_slots (
       slot  	       VARCHAR(30),
       status	       INT(1),
       task	       INT(1),
       hlname	       VARCHAR(30),
       army	       INT(1),
       epoca	       INT(10),
       date	       DATE,
       time	       TIME,
       max_human       INT(2),
       tgt_name	       VARCHAR(50),
       fig_attk_nbr    INT(2),
       fig_def_nbr     INT(2),
       bomb_attk_type  VARCHAR(50),
       bomb_attk_nbr   INT(2),
       bomb_attk_ai    INT(1),
       bomb_def_type   VARCHAR(50),
       bomb_def_nbr    INT(2),
       bomb_def_ai     INT(1)
);

INSERT INTO badc_host_slots (slot, status, task, hlname, army, epoca, date, time, max_human, tgt_name, fig_attk_nbr, fig_def_nbr, bomb_attk_type, bomb_attk_nbr, bomb_attk_ai, bomb_def_type, bomb_def_nbr, bomb_def_ai) VALUES('BW1', '0', '0', '', '0', '0', '', '', '0', '', '0', '0', '', '0', '0', '', '0', '0');

INSERT INTO badc_host_slots (slot, status, task, hlname, army, epoca, date, time, max_human, tgt_name, fig_attk_nbr, fig_def_nbr, bomb_attk_type, bomb_attk_nbr, bomb_attk_ai, bomb_def_type, bomb_def_nbr, bomb_def_ai) VALUES('BW1RR', '0', '1', '', '0', '0', '', '', '0', '', '0', '0', '', '0', '0', '', '0', '0');

INSERT INTO badc_host_slots (slot, status, task, hlname, army, epoca, date, time, max_human, tgt_name, fig_attk_nbr, fig_def_nbr, bomb_attk_type, bomb_attk_nbr, bomb_attk_ai, bomb_def_type, bomb_def_nbr, bomb_def_ai) VALUES('BW1BR', '0', '2', '', '0', '0', '', '', '0', '', '0', '0', '', '0', '0', '', '0', '0');

INSERT INTO badc_host_slots (slot, status, task, hlname, army, epoca, date, time, max_human, tgt_name, fig_attk_nbr, fig_def_nbr, bomb_attk_type, bomb_attk_nbr, bomb_attk_ai, bomb_def_type, bomb_def_nbr, bomb_def_ai) VALUES('BW2', '0', '0', '', '0', '0', '', '', '0', '', '0', '0', '', '0', '0', '', '0', '0');

INSERT INTO badc_host_slots (slot, status, task, hlname, army, epoca, date, time, max_human, tgt_name, fig_attk_nbr, fig_def_nbr, bomb_attk_type, bomb_attk_nbr, bomb_attk_ai, bomb_def_type, bomb_def_nbr, bomb_def_ai) VALUES('BW2RR', '0', '1', '', '0', '0', '', '', '0', '', '0', '0', '', '0', '0', '', '0', '0');

INSERT INTO badc_host_slots (slot, status, task, hlname, army, epoca, date, time, max_human, tgt_name, fig_attk_nbr, fig_def_nbr, bomb_attk_type, bomb_attk_nbr, bomb_attk_ai, bomb_def_type, bomb_def_nbr, bomb_def_ai) VALUES('BW2BR', '0', '2', '', '0', '0', '', '', '0', '', '0', '0', '', '0', '0', '', '0', '0');

INSERT INTO badc_host_slots (slot, status, task, hlname, army, epoca, date, time, max_human, tgt_name, fig_attk_nbr, fig_def_nbr, bomb_attk_type, bomb_attk_nbr, bomb_attk_ai, bomb_def_type, bomb_def_nbr, bomb_def_ai) VALUES('BW3', '0', '0', '', '0', '0', '', '', '0', '', '0', '0', '', '0', '0', '', '0', '0');

INSERT INTO badc_host_slots (slot, status, task, hlname, army, epoca, date, time, max_human, tgt_name, fig_attk_nbr, fig_def_nbr, bomb_attk_type, bomb_attk_nbr, bomb_attk_ai, bomb_def_type, bomb_def_nbr, bomb_def_ai) VALUES('BW3RR', '0', '1', '', '0', '0', '', '', '0', '', '0', '0', '', '0', '0', '', '0', '0');

INSERT INTO badc_host_slots (slot, status, task, hlname, army, epoca, date, time, max_human, tgt_name, fig_attk_nbr, fig_def_nbr, bomb_attk_type, bomb_attk_nbr, bomb_attk_ai, bomb_def_type, bomb_def_nbr, bomb_def_ai) VALUES('BW3BR', '0', '2', '', '0', '0', '', '', '0', '', '0', '0', '', '0', '0', '', '0', '0');

DROP TABLE IF EXISTS badc_mis_prog;
CREATE TABLE badc_mis_prog (
       campanya	       VARCHAR(30),
       mapa	       VARCHAR(30),       
       misnum	       VARCHAR(30),
       host	       VARCHAR(30),
       red_tgt	       VARCHAR(30),
       blue_tgt	       VARCHAR(30),
       red_host	       VARCHAR(30),
       blue_host       VARCHAR(30),
       reported		   INT(1),
       misrep	       VARCHAR(30),
       date	       DATE,
       time	       TIME,
       epoca	       INT(10),
       red_result      VARCHAR(30),
       blue_result      VARCHAR(30),
       coments		   INT(2),
       red_points	   INT(4),
       blue_points	   INT(4),
       side_won		   INT(1),
       human_req	   INT(1),
       rep_date	       DATE,
       rep_time	       TIME,
       rep_epoca      INT(10)
);

DROP TABLE IF EXISTS badc_pilot_file;

CREATE TABLE badc_pilot_file (
       id 		INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
       hlname		VARCHAR(30) BINARY UNIQUE,
       missions		INT(4),
       mis_won		INT(4),
       mis_lost		INT(4),
       ftime		DOUBLE(4,2),
       akills		INT(4),
       akillswf		INT(4),
       gkills		INT(6),
       smoke		INT(6),
       lights		INT(6),
       fired		INT(8),
       ahit		INT(8),
       ahitwf		INT(8),
       ghit		INT(8),
       disco		INT(4),
       killed 		INT(4),
       bailed 		INT(4),
       captured		INT(4),
       landed		INT(4),
       crash		INT(4),
       in_flight	INT(4),
	 in_sqd_name	VARCHAR(8) BINARY ,
	 in_sqd_id	INT(4),
	 sqd_army  INT(1),
	 sqd_accepted  INT(1),
       password	       VARCHAR(32) BINARY ,
	email		VARCHAR(60),
	avatar		VARCHAR(120),
	points		INT(8),
	pnt_steak	INT(8),
	pnt_steak_max	INT(8),
	mis_steak	INT(4),
	mis_steak_max	INT(4),
	a_steak		INT(4),
	a_steak_max	INT(4),
     	g_steak		INT(4),
	g_steak_max	INT(4),
	friend_gk	INT(4),
	friend_ak	INT(4),
	sectors_won	INT(4),
	escort_ok	INT(4),
	intercep_ok	INT(4),
	suply_ok	INT(4),
	recon_ok	INT(4),
	victorias	INT(4),
	fairplay	INT(3),
	rescues		INT(4),
	chutes		INT(4),
	banned		INT(1),
	rank		INT(1),
	medals	INT(4),
	kia_mia		int(4),
	ak_x_mis	DOUBLE(4,2),
	gk_x_mis	DOUBLE(4,2),
	ak_x_kia	DOUBLE(4,2),
	gk_x_kia	DOUBLE(4,2),
	date_join	DATE,
	experience	DOUBLE(4,3),
        aka_alias	VARCHAR(30) BINARY,
	ban_hosting	INT(1),
	ban_planing     INT(1)
);


DROP TABLE IF EXISTS badc_pilot_mis;
CREATE TABLE badc_pilot_mis (
       hlname	       VARCHAR(30) BINARY ,
       plane	       VARCHAR(30),
       command	       VARCHAR(30),
       ftime	       DOUBLE(4,2),
       akills	       INT(3),
       gkills	       INT(3),
	friend_gk	INT(4),
	friend_ak	INT(4),
       chutes	       INT(3),
       smoke	       INT(3),
       lights	       INT(4),
       fired	       INT(4),
       ahit	       INT(4),
       ghit	       INT(4),
       aperc	       DOUBLE(3,2),
       gperc	       DOUBLE(3,2),
       state	       VARCHAR(150),
       misnum	       VARCHAR(30),
       misrep	       VARCHAR(30),
       disco		INT(4),
       killed 		INT(4),
       bailed 		INT(4),
       captured		INT(4),
       landed		INT(4),
       crash		INT(4),
       in_flight	INT(4),
       fuel	       VARCHAR(5),
       weapons	       VARCHAR(40),
       task	       VARCHAR(8),
       points		INT(4),
       campanya	       VARCHAR(30),       
       mapname	       VARCHAR(30)
);

DROP TABLE IF EXISTS badc_rescues;
CREATE TABLE badc_rescues (
       campanya	       VARCHAR(30),
       mapa	       VARCHAR(30),
       misnum	       VARCHAR(30),
       misrep	       VARCHAR(30),
       rescatador	       VARCHAR(30) BINARY ,
       rescatado	       VARCHAR(30) BINARY 
);


DROP TABLE IF EXISTS badc_sqd_file;
CREATE TABLE badc_sqd_file (
	 id		   INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	 sqdname	   VARCHAR(100),
	 sqdname8	   VARCHAR(8) BINARY ,
	 password	   VARCHAR(32) BINARY ,
	 validado	   INT(1),
	 sqd_army	   INT(1),
	 coname		   VARCHAR(30) BINARY ,
	 comail		   VARCHAR(30),
	 xoname		   VARCHAR(30) BINARY ,
	 xomail		   VARCHAR(30),
	 allowxoedit	   INT(1),
	 totalpilot	   INT(3),
	 totalmis	   INT(6),
	 totalakill	   INT(6),
	 totalgkill	   INT(6),
	 totalvict	   INT(6),
	 totalpoints	   INT(8),	
	 sqdweb		   VARCHAR(200),
	 sqdlogo	   VARCHAR(200),
	 date_join	   DATE,
	 totalkiamia	   INT(6),
	 ak_x_mis	   DOUBLE(4,2),	
	 gk_x_mis	   DOUBLE(4,2),
	 points_x_mis	   DOUBLE(4,2),
	 kia_x_mis	   DOUBLE(4,2)
);

INSERT INTO badc_sqd_file 
(sqdname,sqdname8,password,validado,sqd_army,coname,allowxoedit) 
VALUES("default_sqd","NONE","unused_pwd","1","0","Mad","0");


