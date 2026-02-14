-- Source - https://stackoverflow.com/a/2885694
-- Posted by dcp, modified by community. See post 'Timeline' for change history
-- Retrieved 2026-02-14, License - CC BY-SA 3.0

CREATE OR REPLACE PACKAGE testuser.test_pkg IS

   TYPE assoc_array_varchar2_t IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;

   PROCEDURE your_proc(p_parm IN assoc_array_varchar2_t);

END test_pkg;

CREATE OR REPLACE PACKAGE BODY testuser.test_pkg IS

   PROCEDURE your_proc(p_parm IN assoc_array_varchar2_t) AS
   BEGIN
      FOR i IN p_parm.first .. p_parm.last
      LOOP
         dbms_output.put_line(p_parm(i));
      END LOOP;

   END;

END test_pkg;
