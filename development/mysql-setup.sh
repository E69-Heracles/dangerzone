mysql -uroot -e "CREATE DATABASE badc"
mysql -uroot -e "CREATE USER 'badc_user'@'localhost' IDENTIFIED BY 'badc_password'"
mysql -uroot -e "GRANT ALL PRIVILEGES ON badc.* TO badc_user@localhost WITH GRANT OPTION"
mysql badc -ubadc_user -pbadc_password  < /sql/new_tables.sql
mysql badc -ubadc_user -pbadc_password < /sql/votes_tbl.sql
mysql badc -ubadc_user -pbadc_password < /sql/badc_6_HL_slots.sql