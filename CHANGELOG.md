# CHANGELOG

### 0.5.0

* Separate ConvenienceStorePayment from EpsilonGateway and Create new gateway
* Require user_name in detail for purchase method
* Rename number_of_payments to payment_time
* Remove ActiveMerchant::Epsilon::InvalidActionError
* Remove ActiveMerchant::Epsilon::InvalidPaymentMethodError

### 0.4.0

* Support credit card installment payment
* Support credit card revolving payment
* Fix response of credit card payment with 3D secure
* Remove raw_ssl_request method

### 0.3.0

* Support credit card payment with 3D secure
* Disable to specify contract_code with purchase_detail

### 0.2.0

* Specification user_name with purchase_detail

### 0.1.0

* CreditCard verification_value is required by default
