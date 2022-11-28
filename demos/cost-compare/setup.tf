
resource "google_folder" "parent_folder" {
  parent       = var.folder_id
  display_name = "${var.prefix}-${var.demo_name}"
}