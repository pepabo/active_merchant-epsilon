# CHANGELOG

### 0.5.9

* 都度課金、定期課金、コンビニ決済で memo1, memo2 を送信できるようにした
  * [イプシロン開発者向け情報：都度課金](http://www.epsilon.jp/developer/each_time.html)
  * [イプシロン開発者向け情報：定期課金](http://www.epsilon.jp/developer/subscription.html)
  * [イプシロン開発者向け情報：コンビニ決済（決済～入金通知）](http://www.epsilon.jp/developer/conv.html)

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
