

select  a.f_date 日期,'银行存款' 科目名称,a.f_year 年,a.f_period 月,a.f_voucher_group_id_name 凭证字,a.f_voucher_group_no 凭证号,
a.f_explanation 摘要,a.f_account_id_number 对方科目编码,a.f_acct_full_name 对方科目名称,
case when a.f_acct_full_name regexp('应收账款|保证金') then substring_index(a.f_detail_id,'/',-1)
	 else a.f_detail_id
	 end 对方科目核算维度,
a.f_debit 借方金额,
a.f_credit 贷方金额,'借' 方向_1,'' 余额
,case when a.f_acct_full_name regexp('短期借款') and f_debit is null 		then '　　偿还债务支付的现金'
 	  when a.f_acct_full_name regexp('短期借款') and f_debit is not null  then '　　取得借款收到的现金' #？
 	  when a.f_acct_full_name regexp('利息收入') then '　　收到其他与经营活动有关的现金' #?
 	  when a.f_acct_full_name regexp('利息支出') then '　　分配股利、利润或偿付利息支付的现金'
 	  when a.f_acct_full_name regexp('财务费用_手续费|营业外支出|代理推广佣金') then '　　支付其他与经营活动有关的现金'
	  when a.f_acct_full_name regexp('管理费用|销售费用') then
	  	case when f_acct_full_name regexp('福利费') then '　　支付给职工以及为职工支付的现金'
	  	else '　　支付其他与经营活动有关的现金'
	  	end
	  when a.f_acct_full_name regexp('研发费用|应付职工薪酬') then '　　支付给职工以及为职工支付的现金'
 	  when a.f_acct_full_name regexp('深圳榴芒一刻工会|公积金|社保费') then '　　支付给职工以及为职工支付的现金'

 	  when a.f_acct_full_name regexp('其他应付款_暂收款') then '　　销售商品、提供劳务收到的现金'
 	  when a.f_acct_full_name regexp('保证金') then
 	  	case when a.f_debit is not null then  '　　收到其他与经营活动有关的现金'
 	  	else '　　支付其他与经营活动有关的现金'
 	  	end
  	  when a.f_acct_full_name regexp('供应商往来|其他应收款_押金|平台充值|其他应付款_预提费用|其他应收款_上海携程宏睿国际旅行社有限公司|其他应收款_员工往来') then '　　支付其他与经营活动有关的现金'
 	  when a.f_acct_full_name regexp('应付账款_明细应付款') then '　　购买商品、接受劳务支付的现金'	  #?
  	  when a.f_acct_full_name regexp('应交税费') then
  	  	case when a.f_acct_full_name regexp('进项税额') then  '　　支付其他与经营活动有关的现金'
  	  		else '　　支付的各项税费'
  	  	end
  	  when a.f_acct_full_name regexp('代扣个人所得税|地方教育费附加|未交增值税|应交城市|应交教育费|营业税金及附加') then '　　支付的各项税费'
  	  when a.f_acct_full_name regexp('应收账款|主营业务收入|预收账款') then '　　销售商品、提供劳务收到的现金'
--   	  when a.f_acct_full_name regexp('') then ''
	  when a.f_acct_full_name regexp('东莞市榴芒一刻食品有限公司') 			then '　　取得子公司及其他营业单位支付的现金净额'
	  else ''
	 end as 现金流量表科目
from
(select f_date,f_year,f_period,f_voucher_group_id_name,f_voucher_group_no,f_explanation,f_account_id_number,f_acct_full_name,
f_detail_id,f_debit,f_credit,f_bill_no
from   lmykerp_pro.jindie_voucher  where
f_account_book_id_name regexp('深圳')
and f_acct_full_name not in('银行存款')
-- and f_acct_full_name regexp('保证金')
and f_date like '2023-06%' )a
join
(
select  f_bill_no from   lmykerp_pro.jindie_voucher  where
f_account_book_id_name regexp('深圳')
and
f_acct_full_name in('银行存款') and f_date like '2023-06%'
group by f_bill_no)b
on a.f_bill_no=b.f_bill_no




