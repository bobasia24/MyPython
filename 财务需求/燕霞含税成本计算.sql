#燕霞含税成本
select sum(`总成本-含税`)  from (
select
b.序号,b.日期,b.单据编号,b.客户,b.实发数量,b.物料编码,b.物料名称,b.`总成本-不含税`,b.实发数量*a.税额,b.实发数量*a.税额 + b.`总成本-不含税` `总成本-含税`
 from profit.8月出库单列表 b
left join
(select
物料编码,sum(税额) /sum(计价数量) 税额
from profit.2023年8月深圳组织间结算 where 计价数量 !=369593
group by 物料编码)a
on a.物料编码 = b.物料编码)c





 select
b.序号,b.日期,b.单据编号,c.customer,b.实发数量,b.物料编码,b.物料名称,b.`总成本-不含税`,b.实发数量*a.税额,b.实发数量*a.税额 + b.`总成本-不含税` `总成本-含税`
 from profit.8月出库单列表 b
 left join
(
select
b.document_no,b.customer
 from rpa.ods_01财务_rpa_金蝶云星空_销售出库单 b where b.date like '2023-08%' and b.shipment_organization regexp('深圳') group by b.document_no)c
 on b.单据编号 = c.document_no
 left join
(select
物料编码,sum(税额) /sum(计价数量) 税额
from profit.2023年8月深圳组织间结算 where 计价数量 !=369593
group by 物料编码)a
on a.物料编码 = b.物料编码