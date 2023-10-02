terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 1.5.2"

}

provider "yandex" {
  token     = "y0_AgAAAAAGEPMBAATuwQAAAADeJ6zjsolXi-YTSfWMdlAc_AnMqL7N1X4"
  cloud_id  = "b1gls3ojh90ki4m9r2k6"
  folder_id = "b1g3h8pmgcqjp1r19to3"
  zone      = "ru-central1-a"
}
