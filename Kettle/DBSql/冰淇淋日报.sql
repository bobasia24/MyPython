select 发货时间,left(发货时间,7) 年月, 渠道,sum(销量) 总销量,sum(实付金额)实付金额, 货品名称,销售,一级部门,二级部门,简称,
case
	when 发货时间 like '%2024-01%' then CONCAT('01.',row_number()over(partition by left(发货时间,7) order by 发货时间))
    when 发货时间 like '%2024-02%' then CONCAT('02.',row_number()over(partition by left(发货时间,7) order by 发货时间))
	when 发货时间 like '%2024-03%' then CONCAT('03.',row_number()over(partition by left(发货时间,7) order by 发货时间))
	when 发货时间 like '%2024-04%' then CONCAT('04.',row_number()over(partition by left(发货时间,7) order by 发货时间))
	when 发货时间 like '%2024-05%' then CONCAT('05.',row_number()over(partition by left(发货时间,7) order by 发货时间))
    when 发货时间 like '%2024-06%' then CONCAT('06.',row_number()over(partition by left(发货时间,7) order by 发货时间))
	when 发货时间 like '%2024-07%' then CONCAT('07.',row_number()over(partition by left(发货时间,7) order by 发货时间))
	when 发货时间 like '%2024-08%' then CONCAT('08.',row_number()over(partition by left(发货时间,7) order by 发货时间))
	when 发货时间 like '%2024-09%' then CONCAT('09.',row_number()over(partition by left(发货时间,7) order by 发货时间))
    when 发货时间 like '%2024-10%' then CONCAT('10.',row_number()over(partition by left(发货时间,7) order by 发货时间))
	when 发货时间 like '%2024-11%' then CONCAT('11.',row_number()over(partition by left(发货时间,7) order by 发货时间))
	when 发货时间 like '%2024-12%' then CONCAT('12.',row_number()over(partition by left(发货时间,7) order by 发货时间))
end id
,
case when 发货时间 like '%2024-01%' then '01'
     when 发货时间 like '%2024-02%' then '02'
	 when 发货时间 like '%2024-03%' then '03'
	 when 发货时间 like '%2024-04%' then '04'
	 when 发货时间 like '%2024-05%' then '05'
     when 发货时间 like '%2024-06%' then '06'
	 when 发货时间 like '%2024-07%' then '07'
	 when 发货时间 like '%2024-08%' then '08'
	 when 发货时间 like '%2024-09%' then '09'
     when 发货时间 like '%2024-10%' then '10'
	 when 发货时间 like '%2024-11%' then '11'
	 when 发货时间 like '%2024-12%' then '12'
end 父id

from  profit.dw_慧如销售报表冰淇淋
where 发货时间 regexp '2024' and 一级部门 regexp '线上'
group by 发货时间,渠道,货品名称,销售,一级部门,二级部门,简称
order by 发货时间,渠道,简称



select left(发货时间,7) 年月, 渠道,sum(销量) 总销量,sum(实付金额)实付金额, 货品名称,销售,一级部门,二级部门,简称
from  profit.dw_慧如销售报表冰淇淋
where 发货时间 regexp '2024' and 一级部门 regexp '线上'
group by left(发货时间,7) ,渠道,货品名称,销售,一级部门,二级部门,简称
order by 发货时间,渠道,简称








