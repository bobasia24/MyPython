
-- --------------------组织结算校验------------------------

with a as (select  物料编码,含税单价,`税率(%)`
-- ,round(不含税金额/计价数量,2)
from  profit.手动导入_23年9月深圳组织间结算数据 where  物料编码 is not null
group by 物料编码,含税单价,`税率(%)`
order by 物料编码)
select * from a
left join
(
select 物料编码,含税单价,税率 from
profit.ods_深圳组织间结算价目表
group by 物料编码,含税单价,税率)b
on a.物料编码 =b.物料编码
where (a.含税单价 != b.含税单价 or a.`税率(%)` != b.税率 )


-- ----------------------------第一步月初更新出库单成本-----------------------------------------
update
rpa.ods_01财务_rpa_金蝶云星空_销售出库单 a
left join  (
select
material_code,
sum(amount_excluding_tax)/sum(pricing_quantity)  单价
from
rpa.ods_01财务_金蝶_应付单列表_月维度
where business_date like '2023-12%' and payment_organization = '深圳榴芒'
group by material_code )b
on  a.material_code =b.material_code
set a.total_cost = a.issued_quantity*b.单价
where qry_date ='2023-12'
and shipment_organization = '深圳榴芒'

-- ----------------------------------------------------------------------

select sum(total_cost), count(1),sum(issued_quantity)  from rpa.ods_01财务_rpa_金蝶云星空_销售出库单  where `date` like '2023-12%'
and shipment_organization = '深圳榴芒';

-- -----------------------------------------------------------------------
select sum(amount_excluding_tax),sum(pricing_quantity)
from rpa.ods_01财务_金蝶_应付单列表_月维度 where business_date like '2023-12%' and payment_organization = '深圳榴芒'
group by left(business_date,4)


-- --------------------------------月初计算税额 ，第二步，查询导出数据导入至profit.ods_dm_东莞单品成本-----------------------------
select 物料编码,sum(税额)/sum(计价数量)  税额 ,'2023-12' 年月 from
profit.手动导入12月税额
group by 物料编码

-- ---------------------------------------------------------------------------

call sc.pr_金蝶修日复();

CALL profit.pr_get_dpsrcb1();


-- ------------------------------------数据不一致校验--------------------------------------


select * from
(select document_no,sum(issued_quantity) 数量 from rpa.ods_01财务_rpa_金蝶云星空_销售出库单  where `date` like '2023-12%'
and shipment_organization = '深圳榴芒'
group by document_no )a
left join
(select 模块,单据编号,sum(实发数量) 数量  from
profit.dm_单品收入成本
where 发货年月= '202312' and 发货组织  = '深圳榴芒'
group by 单据编号)b
on a.document_no = b.单据编号
where  a.数量 !=  b.数量


