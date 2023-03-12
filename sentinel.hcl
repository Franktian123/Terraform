policy "mandatory-tags-present" {
    source = "./mandatory-tags-present.sentinel"
    enforcement_level= "hard-mandatory"
}

module "mock-tfplan-v2" {
  source = "./mock-tfplan-v2.sentinel"
}
