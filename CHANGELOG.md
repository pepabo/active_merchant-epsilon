# CHANGELOG

### 0.15.0

- [Support 3D Secure parameters for link type payments](https://github.com/pepabo/active_merchant-epsilon/pull/131)

### 0.14.0

- [Support 3D Secure 2.0 for credit card payments](https://github.com/pepabo/active_merchant-epsilon/pull/121)

### 0.13.0

- [Add `last-update` to OrderResponse](https://github.com/pepabo/active_merchant-epsilon/pull/118)

### 0.12.0

- [Add Parameter `delivery_info_required` to purchase method for Epsilon Link Payment](https://github.com/pepabo/active_merchant-epsilon/pull/116)

### 0.11.0

- [Add void mehotd for Epsilon Link Payment](https://github.com/pepabo/active_merchant-epsilon/pull/114)

### 0.10.0

* [Capture authorized payments](https://github.com/pepabo/active_merchant-epsilon/pull/112)

### 0.9.4

* [Support Epsilon Link Payment instead of GMO Payment After Delivery](https://github.com/pepabo/active_merchant-epsilon/pull/110)

### 0.9.3

* [Fix API version for GMO Payment After Delivery](https://github.com/pepabo/active_merchant-epsilon/pull/108)

### 0.9.2

* [Support GMO Payment After Delivery](https://github.com/pepabo/active_merchant-epsilon/pull/106)

### 0.9.1

* [Add amount to response parameters when find order](https://github.com/pepabo/active_merchant-epsilon/pull/99)

### 0.9.0

* [Support virtual account payment](https://github.com/pepabo/active_merchant-epsilon/pull/97)
* [Support to find order](https://github.com/pepabo/active_merchant-epsilon/pull/96)

### 0.8.0
* GMO IDに登録されているクレジットカードで決済できるようにしました。
  * [GMO ID決済の機能を追加した by ryuchan00](https://github.com/pepabo/active_merchant-epsilon/pull/93)

### 0.5.9

* 都度課金、定期課金、コンビニ決済で memo1, memo2 を送信できるようにした #83
  * [イプシロン開発者向け情報：都度課金](http://www.epsilon.jp/developer/each_time.html)
  * [イプシロン開発者向け情報：定期課金](http://www.epsilon.jp/developer/subscription.html)
  * [イプシロン開発者向け情報：コンビニ決済（決済～入金通知）](http://www.epsilon.jp/developer/conv.html)

### 0.5.8

* [Add encoding setting](https://github.com/pepabo/active_merchant-epsilon/pull/82)
  * According to the Epsilon specification, the request parameters must be encode in EUC-JP or Shift_JIS. For the specification, this pull request add encoding setting.

### 0.5.7

* [Fix response parser method by ku00](https://github.com/pepabo/active_merchant-epsilon/pull/81)

### 0.5.6

* [Add company_code to response parameters by ku00 #80](https://github.com/pepabo/active_merchant-epsilon/pull/80)

### 0.5.5

* [Should be able to specify response keys by Joe-noh #79](https://github.com/pepabo/active_merchant-epsilon/pull/79)

### 0.5.4

* [Add validation of accepting only number to phone_number column by woshidan #76](https://github.com/pepabo/active_merchant-epsilon/pull/76)

### 0.5.3

* [Add other convenience store codes by woshidan #75](https://github.com/pepabo/active_merchant-epsilon/pull/75)

### 0.5.2

* [モジュール名 Code をつけないと NameError になるので valid_code? の中の定数にモジュール名をつける by woshidan #71](https://github.com/pepabo/active_merchant-epsilon/pull/71)

### 0.5.1

* [Add change recurring amount method by kurotaky #66](https://github.com/pepabo/active_merchant-epsilon/pull/66)
  * 月次課金の金額変更をできるようにしました
  * 送信パラメータ、受信パラメータに関しては、GMO イプシロンAPI利用マニュアル Ver.1.2.9 - 取引の金額変更 API を参照して下さい

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
