main={RelativeLayout,
    layout_width="fill_parent",
    layout_height="fill_parent",
    gravity="top|center",
  --  orientation="vertical",
    {TextView,
        layout_height="wrap_content",
        text="享受平凡音质",
       textSize="25",
        layout_width="match_parent",
        id="tv_title",
       layout_alignParentTop=true,
        padding="10dp",
        background="#605756",
        textColor="#FFFFFF"},
    {ImageView,
        layout_height="wrap_content",
        layout_width="wrap_content",
       id="back",
        -- src="back",
       layout_margin="10dp",
       layout_centerHorizontal=true,
       layout_centerVertical=true
        },
    {LinearLayout,
        layout_height="wrap_content",
        layout_width="match_parent",
      orientation="vertical",
        id="mainLinearLayout1",
       gravity="bottom|center",
        layout_alignParentBottom=true,
        {LinearLayout,
            layout_height="wrap_content",
            layout_width="match_parent",
           orientation="horizontal",
         -- layout_below="mainImageView1",
            id="mainLinearLayout2",
            gravity="center",
          layout_marginBottom="10dp",
            {TextView,
                layout_height="wrap_content",
                text="00:00",
                id="tv_startTime",
                layout_width="wrap_content"},
            {SeekBar,
                layout_height="wrap_content",
                style="progressBarStyleHorizontal",
                layout_width="wrap_content",
                id="mainProgressBar1",
                id="pb_time",
               layout_weight="1.0"
                },
            {TextView,
                layout_height="wrap_content",
                text="00:00",
                id="tv_endTime",
                layout_width="wrap_content"},
            },
        {LinearLayout,
            layout_height="wrap_content",
            layout_width="match_parent",
            orientation="horizontal",
            --layout_below="mainLinearLayout2",
            gravity="center",
            layout_marginBottom="10dp",
            {Button,
                layout_height="wrap_content",
                text="列表",
                onClick="on_playlist",
                layout_width="wrap_content"},
            {Button,
                layout_height="wrap_content",
                text="<<",
                onClick="on_pre",
                layout_width="wrap_content"},
            {Button,
                layout_height="wrap_content",
                id="bn_pause",
                onClick="on_pause",
                text="■",
                layout_width="wrap_content"},
            {Button,
                layout_height="wrap_content",
                text=">>",
                onClick="on_next",
                layout_width="wrap_content"},
            {Button,
                layout_height="wrap_content",
                text="菜单",
                onClick="on_Menu",
                layout_width="wrap_content"}
            },
        },
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    