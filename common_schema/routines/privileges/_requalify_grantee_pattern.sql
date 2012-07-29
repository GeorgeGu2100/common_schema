-- 
-- Return an unqualified form of grantee, user or host.
-- 
-- The function requalifies given grantee if in grantee format,
-- or returns unqualified text if in apparent user/host format.
--
-- The function returns NULL when the input is not a valid grantee pattern.
--
-- Example:
--
-- SELECT _requalify_grantee_pattern('user.name@some.host')
-- Returns (text): 'user.name'@'some.host'
-- 
DELIMITER $$

DROP FUNCTION IF EXISTS _requalify_grantee_pattern $$
CREATE FUNCTION _requalify_grantee_pattern(grantee_pattern TINYTEXT CHARSET utf8) 
  RETURNS TINYTEXT CHARSET utf8
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Requalify grantee input'

BEGIN
  declare tokens_delimiter VARCHAR(64) CHARSET ascii DEFAULT NULL;
  declare num_tokens INT UNSIGNED DEFAULT 0;

  set grantee_pattern := _retokenized_text(grantee_pattern, '@', '''', TRUE, 'error');
  set tokens_delimiter := @common_schema_retokenized_delimiter;
  set num_tokens := @common_schema_retokenized_count;
  
  if num_tokens = 1 then
    return unquote(grantee_pattern);
  end if;
  if num_tokens = 2 then
    return mysql_grantee(unquote(SUBSTRING_INDEX(grantee_pattern, tokens_delimiter, 1)), unquote(SUBSTRING_INDEX(grantee_pattern, tokens_delimiter, -1)));
  end if;
  return null;
END $$

DELIMITER ;
