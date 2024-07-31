
-- ----------------已弃用，垃圾校验需求------------------------

with a as (select  物料编码,含税单价,`税率(%)`
-- ,round(不含税金额/计价数量,2)
from  profit.人工导入2403组织间结算 where  物料编码 is not null
group by 物料编码,含税单价,`税率(%)`
order by 物料编码)
select * from a
left join
(
select 物料编码,含税单价,`税率%` 税率 from
profit.ods_深圳组织间结算价目表
group by 物料编码,含税单价,税率)b
on a.物料编码 =b.物料编码
where (a.含税单价 != b.含税单价 or a.`税率(%)` != b.税率 )

-- ------------------金蝶与组织结算校验-----------------------

with a as (select  sum(计价单位数量) num1 ,物料编码  from
profit.人工导入2405组织结算_无合计
group by 物料编码 order by 物料编码 )
,b as (
select  material_code ,sum(issued_quantity) num1  from rpa.ods_01财务_rpa_金蝶云星空_销售出库单
where `date` like '2024-05%'
and shipment_organization = '深圳榴芒'
group by material_code order by material_code
)
select * from b left join a
on a.物料编码 = b.material_code
where  a.num1  != b.num1


-- ----------------------------第一步月初更新出库单成本-----------------------------------------

update
rpa.ods_01财务_rpa_金蝶云星空_销售出库单 a
left join  (
select
material_code,
sum(amount_excluding_tax)/sum(pricing_quantity)  单价
from
rpa.ods_01财务_金蝶_应付单列表_月维度
where business_date like '2024-05%' and payment_organization = '深圳榴芒'
group by material_code )b
on  a.material_code =b.material_code
set a.total_cost = a.issued_quantity*b.单价
where qry_date ='2024-05'
and shipment_organization = '深圳榴芒'

-- ----------------------------------------------------------------------

select sum(total_cost), count(1),sum(issued_quantity)  from rpa.ods_01财务_rpa_金蝶云星空_销售出库单  where `date` like '2024-05%'
and shipment_organization = '深圳榴芒';

-- -----------------------------------------------------------------------

select sum(amount_excluding_tax),sum(pricing_quantity)
from rpa.ods_01财务_金蝶_应付单列表_月维度 where business_date like '2024-05%' and payment_organization = '深圳榴芒'
group by left(business_date,4)

-- --------------------------------月初计算税额 ，第二步，查询导出数据导入至profit.ods_dm_东莞单品成本-----------------------------

select 物料编码,sum(税额)/sum(计价单位数量)  税额 ,'2024-05' 年月,物料名称 from
profit.人工导入2405组织结算_无合计
group by 物料编码

select sum(计价单位数量) from
profit.人工导入2405组织结算_无合计

-- ----------------------启动lmyk.sh脚本-----------------------------------------------------
-- ----------------------校验非自营报价-----------------------------------------------------

select
channel,commodity,amount_of_money,`date`,count(1) num
from sc.fill_非自营商品报价表 f非
group by channel,commodity,amount_of_money ,`date`,活动开始时间
having count(1)  >1

-- -----------------------------------------------------

call sc.pr_金蝶修日复();

CALL profit.pr_get_dpsrcb1();

-- ------------------------------------金额、数量不一致校验--------------------------------------



with a as (
select round(sum(total_cost),3)  金蝶金额,round(sum(issued_quantity),3)  金蝶销量,document_no  from rpa.ods_01财务_rpa_金蝶云星空_销售出库单
where `date` like '2024-05%'
and shipment_organization = '深圳榴芒' group by  document_no)
,b as (select  round( sum(销售成本),3)单品金额 ,round(sum(实发数量),3)  单品销量,单据编号 from
profit.dm_单品收入成本
where 发货年月 = '202405'  and 发货组织 regexp '深圳'
group by 单据编号)
select * from a left join b
on a.document_no = b.单据编号
where (a.金蝶销量 != b.单品销量 or a.金蝶金额 != b.单品金额 )


