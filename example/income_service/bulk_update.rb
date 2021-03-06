# -*- coding: utf-8 -*-

if ARGV.length < 5 || (ARGV.length - 1) % 4 != 0
  $stderr.puts(<<-EOS)
Usage:
  bulk_update.rb <patient_id> <in_out> <invoice_number> <ic_clas> <ic_money> [<in_out> <invoice_number> <ic_class> <ic_money> ...]
    in_out: i or o
    ic_class: 1 = pay, 2 = pay_back
  EOS
  exit(1)
end

require_relative "../common"

income_service = @orca_api.new_income_service

patient_id = ARGV.shift
income_informations = []
while (in_out = ARGV.shift&.upcase)
  invoice_number = ARGV.shift
  ic_class = ARGV.shift
  ic_money = ARGV.shift

  income_informations << {
    "InOut" => in_out, # 入外区分、I:入院/O:外来/必須/1
    "Invoice_Number" => invoice_number, # 伝票番号/必須/7
    "Processing_Date" => "", # 処理日/任意/10/未設定時の初期値はシステム日付（実際の処理日）
    "Processing_Time" => "", # 処理時刻/任意/8/未設定時の初期値はシステム時刻（実際の処理時刻）
    "Ic_Class" => ic_class, # 入返金区分、1:入金、2:返金/必須/1
    "Ic_Money" => ic_money, # 入金額/必須/10
    "Ic_Code" => "", # 入金方法/システム管理［1041 入金方法情報］より設定/任意/2/未設定時の初期値は患者登録設定内容
    "Force_Ic" => "", # 強制入金フラグ、True:請求金額＜入金額となる入金をエラーとしない、False:請求金額＜入金額となる入金をエラーとする/任意/5/未設定時の初期値は"False"
  }
end

args = {
  "Patient_ID" => patient_id, # 患者番号/必須/20
  "Income_Information" => income_informations, # 請求情報（繰り返し　最大５００）
}
result = income_service.bulk_update(args)
if result.ok?
  print_result(result)
else
  error(result)
end
