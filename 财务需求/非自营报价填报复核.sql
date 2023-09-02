 select *,
 substring(REGEXP_SUBSTR(商品, '[^,]+', 1, 1),LOCATE(')',REGEXP_SUBSTR(商品, '[^,]+', 1, 1))+1,100)  AS '一级名称',
 REPLACE(SUBSTRING_INDEX(REGEXP_SUBSTR(商品, '[^,]+', 1, 1),')',1),'(','')  as '一级数量',
 '' as '一级单价',

substring(REGEXP_SUBSTR(商品, '[^,]+', 1, 2),LOCATE(')',REGEXP_SUBSTR(商品, '[^,]+', 1, 2))+1,100)  AS '二级名称',
REPLACE(SUBSTRING_INDEX(REGEXP_SUBSTR(商品, '[^,]+', 1, 2),')',1),'(','')  as '二级数量',
'' as '二级单价',

substring(REGEXP_SUBSTR(商品, '[^,]+', 1, 3),LOCATE(')',REGEXP_SUBSTR(商品, '[^,]+', 1, 3))+1,100) AS '三级名称' ,
REPLACE(SUBSTRING_INDEX(REGEXP_SUBSTR(商品, '[^,]+', 1, 3),')',1),'(','')  as '三级数量',
'' as '三级单价',

substring(REGEXP_SUBSTR(商品, '[^,]+', 1, 4),LOCATE(')',REGEXP_SUBSTR(商品, '[^,]+', 1, 4))+1,100) AS '四级名称' ,
REPLACE(SUBSTRING_INDEX(REGEXP_SUBSTR(商品, '[^,]+', 1, 4),')',1),'(','')  as '四级数量',
'' as '四级单价',

substring(REGEXP_SUBSTR(商品, '[^,]+', 1, 5),LOCATE(')',REGEXP_SUBSTR(商品, '[^,]+', 1, 5))+1,100) AS '五级名称' ,
REPLACE(SUBSTRING_INDEX(REGEXP_SUBSTR(商品, '[^,]+', 1, 5),')',1),'(','')  as '五级数量',
'' as '五级单价',

substring(REGEXP_SUBSTR(商品, '[^,]+', 1, 6),LOCATE(')',REGEXP_SUBSTR(商品, '[^,]+', 1, 6))+1,100) AS '六级名称' ,
REPLACE(SUBSTRING_INDEX(REGEXP_SUBSTR(商品, '[^,]+', 1, 6),')',1),'(','')  as '六级数量',
'' as '六级单价',

substring(REGEXP_SUBSTR(商品, '[^,]+', 1, 7),LOCATE(')',REGEXP_SUBSTR(商品, '[^,]+', 1, 7))+1,100) AS '七级名称' ,
REPLACE(SUBSTRING_INDEX(REGEXP_SUBSTR(商品, '[^,]+', 1, 7),')',1),'(','')  as '七级数量',
'' as '七级单价',

substring(REGEXP_SUBSTR(商品, '[^,]+', 1, 8),LOCATE(')',REGEXP_SUBSTR(商品, '[^,]+', 1, 8))+1,100) AS '八级名称' ,
REPLACE(SUBSTRING_INDEX(REGEXP_SUBSTR(商品, '[^,]+', 1, 8),')',1),'(','')  as '八级数量',
'' as '八级单价',

substring(REGEXP_SUBSTR(商品, '[^,]+', 1, 9),LOCATE(')',REGEXP_SUBSTR(商品, '[^,]+', 1, 9))+1,100) AS '九级名称' ,
REPLACE(SUBSTRING_INDEX(REGEXP_SUBSTR(商品, '[^,]+', 1, 9),')',1),'(','')  as '九级数量',
'' as '九级单价',

substring(REGEXP_SUBSTR(商品, '[^,]+', 1, 10),LOCATE(')',REGEXP_SUBSTR(商品, '[^,]+', 1, 10))+1,100) AS '十级名称' ,
REPLACE(SUBSTRING_INDEX(REGEXP_SUBSTR(商品, '[^,]+', 1, 10),')',1),'(','')  as '十级数量',
'' as '十级单价',

substring(REGEXP_SUBSTR(商品, '[^,]+', 1, 11),LOCATE(')',REGEXP_SUBSTR(商品, '[^,]+', 1, 11))+1,100) AS '十一级名称' ,
REPLACE(SUBSTRING_INDEX(REGEXP_SUBSTR(商品, '[^,]+', 1, 11),')',1),'(','')  as '十一级数量',
'' as '十一级单价',

substring(REGEXP_SUBSTR(商品, '[^,]+', 1, 12),LOCATE(')',REGEXP_SUBSTR(商品, '[^,]+', 1, 12))+1,100) AS '十二级名称' ,
REPLACE(SUBSTRING_INDEX(REGEXP_SUBSTR(商品, '[^,]+', 1, 12),')',1),'(','')  as '十二级数量',
'' as '十二级单价',

substring(REGEXP_SUBSTR(商品, '[^,]+', 1, 13),LOCATE(')',REGEXP_SUBSTR(商品, '[^,]+', 1, 13))+1,100) AS '十三级名称' ,
REPLACE(SUBSTRING_INDEX(REGEXP_SUBSTR(商品, '[^,]+', 1, 13),')',1),'(','')  as '十三级数量',
'' as '十三级单价',

substring(REGEXP_SUBSTR(商品, '[^,]+', 1, 14),LOCATE(')',REGEXP_SUBSTR(商品, '[^,]+', 1, 14))+1,100) AS '十四级名称' ,
REPLACE(SUBSTRING_INDEX(REGEXP_SUBSTR(商品, '[^,]+', 1, 14),')',1),'(','')  as '十四级数量',
'' as '十四级单价',

substring(REGEXP_SUBSTR(商品, '[^,]+', 1, 15),LOCATE(')',REGEXP_SUBSTR(商品, '[^,]+', 1, 15))+1,100) AS '十五级名称' ,
REPLACE(SUBSTRING_INDEX(REGEXP_SUBSTR(商品, '[^,]+', 1, 15),')',1),'(','')  as '十五级数量',
'' as '十五级单价'

FROM 非自营报价填报复核
--  where 渠道='池渊鑫海-sz' and 商品='(44)猫山王榴莲冰皮月饼408克(68克*6)8盒/箱,(40)组合冰皮月饼680克(68克*10)8盒/箱,(42)金枕榴莲冰皮月饼680克(68克*10)8盒/箱' ;
