resource "shoreline_notebook" "corrupted_mysql_tables" {
  name       = "corrupted_mysql_tables"
  data       = file("${path.module}/data/corrupted_mysql_tables.json")
  depends_on = [shoreline_action.invoke_check_mysql_recovery,shoreline_action.invoke_restore_db,shoreline_action.invoke_repair_optimize_table,shoreline_action.invoke_create_restore_table]
}

resource "shoreline_file" "check_mysql_recovery" {
  name             = "check_mysql_recovery"
  input_file       = "${path.module}/data/check_mysql_recovery.sh"
  md5              = filemd5("${path.module}/data/check_mysql_recovery.sh")
  description      = "Check to see if the DB server shutdown leading to incomplete transactions."
  destination_path = "/tmp/check_mysql_recovery.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "restore_db" {
  name             = "restore_db"
  input_file       = "${path.module}/data/restore_db.sh"
  md5              = filemd5("${path.module}/data/restore_db.sh")
  description      = "Restore from Backup: If you have a recent backup of your MySQL database, restoring it to a point before the corruption occurred will resolve the issue. This is assuming that the backup itself is not corrupted."
  destination_path = "/tmp/restore_db.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "repair_optimize_table" {
  name             = "repair_optimize_table"
  input_file       = "${path.module}/data/repair_optimize_table.sh"
  md5              = filemd5("${path.module}/data/repair_optimize_table.sh")
  description      = "Repair and Optimize: MySQL has a built-in repair and optimize function that can help fix corrupted tables. You can use the following command in the MySQL client: "
  destination_path = "/tmp/repair_optimize_table.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "create_restore_table" {
  name             = "create_restore_table"
  input_file       = "${path.module}/data/create_restore_table.sh"
  md5              = filemd5("${path.module}/data/create_restore_table.sh")
  description      = "Attempt the MYSQL dump and reload method for corrupted tables"
  destination_path = "/tmp/create_restore_table.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_check_mysql_recovery" {
  name        = "invoke_check_mysql_recovery"
  description = "Check to see if the DB server shutdown leading to incomplete transactions."
  command     = "`chmod +x /tmp/check_mysql_recovery.sh && /tmp/check_mysql_recovery.sh`"
  params      = ["PATH_TO_MYSQL_ERRORLOG","PATH_TO_MYSQL_LOGFILE"]
  file_deps   = ["check_mysql_recovery"]
  enabled     = true
  depends_on  = [shoreline_file.check_mysql_recovery]
}

resource "shoreline_action" "invoke_restore_db" {
  name        = "invoke_restore_db"
  description = "Restore from Backup: If you have a recent backup of your MySQL database, restoring it to a point before the corruption occurred will resolve the issue. This is assuming that the backup itself is not corrupted."
  command     = "`chmod +x /tmp/restore_db.sh && /tmp/restore_db.sh`"
  params      = ["NAME_OF_DATABASE","PATH_TO_BACKUP_FILE","PASSWORD","USERNAME"]
  file_deps   = ["restore_db"]
  enabled     = true
  depends_on  = [shoreline_file.restore_db]
}

resource "shoreline_action" "invoke_repair_optimize_table" {
  name        = "invoke_repair_optimize_table"
  description = "Repair and Optimize: MySQL has a built-in repair and optimize function that can help fix corrupted tables. You can use the following command in the MySQL client: "
  command     = "`chmod +x /tmp/repair_optimize_table.sh && /tmp/repair_optimize_table.sh`"
  params      = ["DATABASE_NAME","PASSWORD","TABLE_NAME","USERNAME"]
  file_deps   = ["repair_optimize_table"]
  enabled     = true
  depends_on  = [shoreline_file.repair_optimize_table]
}

resource "shoreline_action" "invoke_create_restore_table" {
  name        = "invoke_create_restore_table"
  description = "Attempt the MYSQL dump and reload method for corrupted tables"
  command     = "`chmod +x /tmp/create_restore_table.sh && /tmp/create_restore_table.sh`"
  params      = ["DATABASE_NAME","PATH_TO_BACKUP_FILE","TABLE_NAME"]
  file_deps   = ["create_restore_table"]
  enabled     = true
  depends_on  = [shoreline_file.create_restore_table]
}

