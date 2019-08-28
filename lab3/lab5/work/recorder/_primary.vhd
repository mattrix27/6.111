library verilog;
use verilog.vl_types.all;
entity recorder is
    port(
        clock           : in     vl_logic;
        reset           : in     vl_logic;
        playback        : in     vl_logic;
        ready           : in     vl_logic;
        filter          : in     vl_logic;
        from_memory     : in     vl_logic_vector(7 downto 0);
        to_memory       : out    vl_logic_vector(7 downto 0);
        addr            : out    vl_logic_vector(15 downto 0);
        \record\        : out    vl_logic;
        from_ac97_data  : in     vl_logic_vector(7 downto 0);
        to_ac97_data    : out    vl_logic_vector(7 downto 0);
        counter         : out    vl_logic_vector(2 downto 0)
    );
end recorder;
