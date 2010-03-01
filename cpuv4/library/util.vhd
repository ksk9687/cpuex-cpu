

-- @module : util
-- @author : ksk
-- @date   : 2009/10/07


library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;

package util is
   function sign_extention (a:std_logic_vector) return std_logic_vector;
   	
	
end package util;  
 
 
package body util is
  function sign_extention (a:std_logic_vector) return std_logic_vector is
	variable r : std_logic_vector(31 downto 0);
  begin
    for i in a'RANGE loop
     r(i) := a(i);
    end loop;
    for i in a'HIGH+1 to 31 loop
     r(i) := a(a'HIGH);
    end loop;
  	return r;
  end sign_extention;
end util;
	






