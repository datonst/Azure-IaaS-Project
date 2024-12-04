# Hướng dẫn sử dụng  

1. Cài Azure CLI, đăng nhập bằng `az login`, chạy `az account list --output table` để lấy `subscription_id`.  
2. Vào file `dev/versions.tf`, chỉnh lại `subscription_id` vừa lấy.  
3. Vào folder `dev`, chạy lần lượt các lệnh:  
   ```bash
   terraform init  
   terraform plan  
   terraform apply  


