create or replace package PKG_PIVOT is
--Взято с http://habrahabr.ru/blogs/oracle/100798/ по мотивам Кайта
 function pivot_sql (
                     p_max_cols_query in varchar2 default null
                    , p_query in varchar2
                    , p_anchor in varchar2_table
                    , p_pivot in varchar2_table
                    , p_pivot_head_sql in varchar2_table default varchar2_table()
                    )
 return varchar2;

 function pivot_ref (
                        p_max_cols_query in varchar2 default null
                     , p_query in varchar2
                     , p_anchor in varchar2_table
                     , p_pivot in varchar2_table
                     , p_pivot_name in varchar2_table default varchar2_table()
                     )
 return sys_refcursor;
 function test_sql(colName varchar2 := 'd') return varchar2;

end PKG_PIVOT;
/
create or replace package body PKG_PIVOT is
/**
* Function returning query
*/
 function pivot_sql (
                     p_max_cols_query in varchar2 default null
                    , p_query in varchar2
                    , p_anchor in varchar2_table
                    , p_pivot in varchar2_table
                    , p_pivot_head_sql in varchar2_table
                    ) return varchar2
                    is
    l_max_cols number;
    l_query varchar2(4000);
    l_pivot_name varchar2_table:=varchar2_table();
    k integer;
    c1 sys_refcursor;
    v varchar2(30);
 begin
    -- Получаем кол-во столбцов
    if (p_max_cols_query is not null) then
     execute immediate p_max_cols_query
        into l_max_cols;
    else
     raise_application_error (-20001, 'Cannot figure out max cols');
    end if;

    -- Собираем по кускам необходимый нам запрос
    l_query := 'select ';

    for i in 1 .. p_anchor.count loop
     l_query := l_query || p_anchor (i) || ',';
    end loop;
    --Получаем названия колонок
    k:=1;
    if p_pivot_head_sql.count=p_pivot.count
     then
         for j in 1 .. p_pivot.count loop
            open c1 for p_pivot_head_sql(j);
            loop
             fetch c1 into v;
             l_pivot_name.extend(1);
             l_pivot_name(k):=v;
             EXIT WHEN c1%NOTFOUND;
             k:=k+1;
            end loop;
         end loop;
    end if;

    -- Добавляем колонки с полученными названиями
    -- в виде "max(decode(rn,1,C{X+1},null)) c_name+1_1"
    for i in 1 .. l_max_cols loop
     for j in 1 .. p_pivot.count loop
        l_query := l_query || 'max(decode(rn,' || i || ',' || p_pivot (j) || ',null)) '
                  ||'"' ||l_pivot_name ((j-1)*l_max_cols+i) ||'"'|| ',';
     end loop;
    end loop;

    -- Вставляем исходный запрос
    l_query := rtrim (l_query, ',') || ' from ( ' || p_query || ') group by ';

    -- Группируем по колонкам
    for i in 1 .. p_anchor.count loop
     l_query := l_query || p_anchor (i) || ',';
    end loop;

    l_query := rtrim (l_query, ',');

    -- Возвращаем готовый SQL запрос
    return l_query;
 end;

/**
* Функция возвращающая курсор на выполненный запрос
*/
 function pivot_ref (
                     p_max_cols_query in varchar2 default null
                    , p_query in varchar2
                    , p_anchor in varchar2_table
                    , p_pivot in varchar2_table
                    , p_pivot_name in varchar2_table
                    ) return sys_refcursor
                    is
    p_cursor sys_refcursor;
 begin
    execute immediate 'alter session set cursor_sharing=force';
    open p_cursor for pkg_pivot.pivot_sql (
                     p_max_cols_query
                    , p_query
                    , p_anchor
                    , p_pivot
                    , p_pivot_name
                    );
    execute immediate 'alter session set cursor_sharing=exact';
    return p_cursor;
 end;
function test_sql(colName varchar2) return varchar2
is
begin
return 'select deviceid,max(decode(rn,1,cnt,null)) "01-NOV-11",max(decode(rn,2,cnt,null)) "02-NOV-11",max(decode(rn,3,cnt,null)) "03-NOV-11",max(decode(rn,4,cnt,null)) "04-NOV-11",max(decode(rn,5,cnt,null)) "05-NOV-11",max(decode(rn,6,cnt,null)) "06-NOV-11",max(decode(rn,7,cnt,null)) "07-NOV-11",max(decode(rn,8,cnt,null)) "08-NOV-11",max(decode(rn,9,cnt,null)) "09-NOV-11",max(decode(rn,10,cnt,null)) "10-NOV-11",max(decode(rn,11,cnt,null)) "11-NOV-11",max(decode(rn,12,cnt,null)) "12-NOV-11",max(decode(rn,13,cnt,null)) "13-NOV-11",max(decode(rn,14,cnt,null)) "14-NOV-11",max(decode(rn,15,cnt,null)) "15-NOV-11",max(decode(rn,16,cnt,null)) "16-NOV-11",max(decode(rn,17,cnt,null)) "17-NOV-11",max(decode(rn,18,cnt,null)) "18-NOV-11",max(decode(rn,19,cnt,null)) "19-NOV-11",max(decode(rn,20,cnt,null)) "20-NOV-11",max(decode(rn,21,cnt,null)) "21-NOV-11",max(decode(rn,22,cnt,null)) "22-NOV-11",max(decode(rn,23,cnt,null)) "23-NOV-11",max(decode(rn,24,cnt,null)) "24-NOV-11",max(decode(rn,25,cnt,null)) "25-NOV-11",max(decode(rn,26,cnt,null)) "26-NOV-11",max(decode(rn,27,cnt,null)) "27-NOV-11",max(decode(rn,28,cnt,null)) "28-NOV-11",max(decode(rn,29,cnt,null)) "29-NOV-11",max(decode(rn,30,cnt,null)) "30-NOV-11" from ( select t.deviceid, count(t.deviceid) cnt, trunc(t.gdate), dense_rank() over(order by trunc(t.gdate)) rn from coordinate_v@gps t where to_char(t.gdate,''yyyy'') = ''2011'' and to_char(t.gdate,''mm'') = ''11'' group by t.deviceid, trunc(t.gdate)) group by deviceid';
     --    return 'select dummy from dual where ''1''=''1''';
--         return 'select deviceid,max(decode(rn,1,cnt,null)) "01-NOV-11",max(decode(rn,2,cnt,null)) "02-NOV-11",max(decode(rn,3,cnt,null)) "03-NOV-11",max(decode(rn,4,cnt,null)) "04-NOV-11",max(decode(rn,5,cnt,null)) "05-NOV-11",max(decode(rn,6,cnt,null)) "06-NOV-11",max(decode(rn,7,cnt,null)) "07-NOV-11",max(decode(rn,8,cnt,null)) "08-NOV-11",max(decode(rn,9,cnt,null)) "09-NOV-11",max(decode(rn,10,cnt,null)) "10-NOV-11",max(decode(rn,11,cnt,null)) "11-NOV-11",max(decode(rn,12,cnt,null)) "12-NOV-11",max(decode(rn,13,cnt,null)) "13-NOV-11",max(decode(rn,14,cnt,null)) "14-NOV-11",max(decode(rn,15,cnt,null)) "15-NOV-11",max(decode(rn,16,cnt,null)) "16-NOV-11",max(decode(rn,17,cnt,null)) "17-NOV-11",max(decode(rn,18,cnt,null)) "18-NOV-11",max(decode(rn,19,cnt,null)) "19-NOV-11",max(decode(rn,20,cnt,null)) "20-NOV-11",max(decode(rn,21,cnt,null)) "21-NOV-11",max(decode(rn,22,cnt,null)) "22-NOV-11",max(decode(rn,23,cnt,null)) "23-NOV-11",max(decode(rn,24,cnt,null)) "24-NOV-11",max(decode(rn,25,cnt,null)) "25-NOV-11",max(decode(rn,26,cnt,null)) "26-NOV-11",max(decode(rn,27,cnt,null)) "27-NOV-11",max(decode(rn,28,cnt,null)) "28-NOV-11",max(decode(rn,29,cnt,null)) "29-NOV-11",max(decode(rn,30,cnt,null)) "30-NOV-11" from ( select t.deviceid, count(t.deviceid) cnt, trunc(t.gdate), dense_rank() over(order by trunc(t.gdate)) rn from coordinate_v@gps t where to_char(t.gdate,''yyyy'') = ''2011'' and to_char(t.gdate,''mm'') = ''11'' group by t.deviceid, trunc(t.gdate)) group by deviceid';
               --  select deviceid,max(decode(rn,1,cnt,null)) "01-NOV-11",max(decode(rn,2,cnt,null)) "02-NOV-11",max(decode(rn,3,cnt,null)) "03-NOV-11",max(decode(rn,4,cnt,null)) "04-NOV-11",max(decode(rn,5,cnt,null)) "05-NOV-11",max(decode(rn,6,cnt,null)) "06-NOV-11",max(decode(rn,7,cnt,null)) "07-NOV-11",max(decode(rn,8,cnt,null)) "08-NOV-11",max(decode(rn,9,cnt,null)) "09-NOV-11",max(decode(rn,10,cnt,null)) "10-NOV-11",max(decode(rn,11,cnt,null)) "11-NOV-11",max(decode(rn,12,cnt,null)) "12-NOV-11",max(decode(rn,13,cnt,null)) "13-NOV-11",max(decode(rn,14,cnt,null)) "14-NOV-11",max(decode(rn,15,cnt,null)) "15-NOV-11",max(decode(rn,16,cnt,null)) "16-NOV-11",max(decode(rn,17,cnt,null)) "17-NOV-11",max(decode(rn,18,cnt,null)) "18-NOV-11",max(decode(rn,19,cnt,null)) "19-NOV-11",max(decode(rn,20,cnt,null)) "20-NOV-11",max(decode(rn,21,cnt,null)) "21-NOV-11",max(decode(rn,22,cnt,null)) "22-NOV-11",max(decode(rn,23,cnt,null)) "23-NOV-11",max(decode(rn,24,cnt,null)) "24-NOV-11",max(decode(rn,25,cnt,null)) "25-NOV-11",max(decode(rn,26,cnt,null)) "26-NOV-11",max(decode(rn,27,cnt,null)) "27-NOV-11",max(decode(rn,28,cnt,null)) "28-NOV-11",max(decode(rn,29,cnt,null)) "29-NOV-11",max(decode(rn,30,cnt,null)) "30-NOV-11" from ( select t.deviceid, count(t.deviceid) cnt, trunc(t.gdate), dense_rank() over(order by trunc(t.gdate)) rn from coordinate_v     t where to_char(t.gdate,''yyyy'') = ''2011'' and to_char(t.gdate,''mm'') = ''11'' group by t.deviceid, trunc(t.gdate)) group by deviceid
--         return 'select deviceid,max(decode(rn,1,cnt,null)) "01-NOV-11",max(decode(rn,2,cnt,null)) "02-NOV-11",max(decode(rn,3,cnt,null)) "03-NOV-11",max(decode(rn,4,cnt,null)) "04-NOV-11",max(decode(rn,5,cnt,null)) "05-NOV-11",max(decode(rn,6,cnt,null)) "06-NOV-11",max(decode(rn,7,cnt,null)) "07-NOV-11",max(decode(rn,8,cnt,null)) "08-NOV-11",max(decode(rn,9,cnt,null)) "09-NOV-11",max(decode(rn,10,cnt,null)) "10-NOV-11",max(decode(rn,11,cnt,null)) "11-NOV-11",max(decode(rn,12,cnt,null)) "12-NOV-11",max(decode(rn,13,cnt,null)) "13-NOV-11",max(decode(rn,14,cnt,null)) "14-NOV-11",max(decode(rn,15,cnt,null)) "15-NOV-11",max(decode(rn,16,cnt,null)) "16-NOV-11",max(decode(rn,17,cnt,null)) "17-NOV-11",max(decode(rn,18,cnt,null)) "18-NOV-11",max(decode(rn,19,cnt,null)) "19-NOV-11",max(decode(rn,20,cnt,null)) "20-NOV-11",max(decode(rn,21,cnt,null)) "21-NOV-11",max(decode(rn,22,cnt,null)) "22-NOV-11",max(decode(rn,23,cnt,null)) "23-NOV-11",max(decode(rn,24,cnt,null)) "24-NOV-11",max(decode(rn,25,cnt,null)) "25-NOV-11",max(decode(rn,26,cnt,null)) "26-NOV-11",max(decode(rn,27,cnt,null)) "27-NOV-11",max(decode(rn,28,cnt,null)) "28-NOV-11",max(decode(rn,29,cnt,null)) "29-NOV-11",max(decode(rn,30,cnt,null)) "30-NOV-11" from ( select t.deviceid, count(t.deviceid) cnt, trunc(t.gdate), dense_rank() over(order by trunc(t.gdate)) rn from coordinate_v@gps t  group by t.deviceid, trunc(t.gdate)) group by deviceid';
end;
 
end PKG_PIVOT;
/
