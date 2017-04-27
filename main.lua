require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.View_*"
import "android.media.*"
import "android.view.*"
import "android.content.*"
import "java.io.*"
import "java.util.*"
import "java.lang.*"
import "android.content.Context"
import "android.provider.*"
require "layout"
activity.setTitle("美美播放器")
activity.setTheme(android.R.style.Theme_Holo_Light)
local arr=nil
local pd--扫描进度条,定义在这容易操作
local mp=MediaPlayer()
local t=nil
local isPlay=false
local curPlay=nil --当前正在播放的mp3的路径
local listpath="/sdcard/playlist.txt"
local tf=File(listpath)
local dur--歌曲长度
local cur--播放当前位置
local min,sec=0,0--分和秒
local curIdx=0--当前播放的mp3在列表中的索引
local th=nil--线程

--播放音乐，不异步可控
--@mp MediaPlayer对象
--@path 歌曲完整路径
function play(mp,path)
  mp.reset()
  mp.setDataSource(path)
  mp.prepare()
  mp.start()
end
--更新内容
function updateProgress(path)
   pd.setMessage(path)
  end
--回调函数，获取某文件夹下所有mp3文件完成时被调用
function getListFinish()
  writeFile(listpath,arr)
  pd.cancel()
  th.quit()--退出线程
  print("扫描完毕")
end
--获取文件夹下的所有mp3文件。并存在arr中
--利用广度优先搜索
function getFiles(arr,path)
  require "import"
  import "java.util.*"
  import "java.io.*"
  local queue=LinkedList()--模拟一个队列
    local f=File(path)
    local  ls=f.listFiles()
    for i=0,#ls-1 do
      local t=ls[i]
      local name=t.getName();
      if t.isDirectory() then--是文件夹
       queue.addLast(t)
      else
       if string.find(string.lower(name),"%.mp3$") and t.length()>1024*1024*2 then
         arr.add(t)
         end--if
      end--if
      end--for
    while(queue.isEmpty()==false) do
   local dirtemp= queue.removeFirst()
  
   call("updateProgress","已扫描到"..arr.size().."个mp3文件\n"..dirtemp.getPath())
   local  listtemp=dirtemp.listFiles()
    for i=0,#listtemp-1 do
      local t=listtemp[i]
      local name=t.getName();
      if t.isDirectory() then--是文件夹
       queue.addLast(t)
      else
       if string.find(string.lower(name),"%.mp3$") and t.length()>1024*1024*2 then
         arr.add(t)
         end--if
      end--if
      end--for
    end--while
    call("getListFinish")
    end --getFiles


--获取某文件夹下所有mp3文件。并存在arr中
function getList(path)
  arr=ArrayList()
  th=thread(getFiles,arr,path)
  th.getFiles(arr,path)
end

--写入文件
--@path  文件完整路径
--@list    ArrayList
function writeFile(path,list)
  local fw=FileWriter(path)
  local bw=BufferedWriter(fw)
  for i=0,list.size()-1 do
    str=list.get(i).toString()
    bw.write(str,0,utf8.len(str))
    bw.newLine()
  end
  bw.flush()
  bw.close()
end
--读文件
--path 完整路径
--return ArrayList
function readFile(path)
  local al=ArrayList()
  local fr=FileReader(path)
  local br=BufferedReader(fr)
  local ch=0
  while(br.read()~=-1 )
  do
    al.add(br.readLine())
  end
  br.close()
  return al
end

--显示歌曲列表
--@path 列表文件路径
--@mediaplayer
function showList(path,mp)
  local al= readFile(path)
  arr=al
  local names={}
  local paths={}
  for i=0,al.size()-1 do
    table.insert(paths,al.get(i))
    table.insert(names,File(al.get(i)).getName())

  end
  local ad= AlertDialog.Builder(activity)
  ad.setTitle("歌曲列表")
  ad.setItems(String(names)
  ,DialogInterface.OnClickListener{
    onClick=function(dialog,which)
      curPlay=paths[which+1]
      curIdx=which
      play(mp,curPlay)
      local tt=string.gsub(names[which+1],".mp3$","")--偷懒一下
      tv_title.setText(tt)
    end
  })

  ad.setNegativeButton( "取消", nil)
  ad= ad.create()
  local window = ad.getWindow()
  local lp = window.getAttributes()
  --设置透明度
  lp.alpha = 0.8
  window.setAttributes(lp)
  ad.show()
end
--弹出进度条
--@text 进度条的文本
function showProcessBar(text)
  pd = ProgressDialog
  .show(activity, nil, text)
  pd.setCancelable(false)--扫描中不能取消
end


--弹出文本框对话框
--@pa 进度条对象
function showEditDialog(msg)
  local edit=EditText(activity)
  edit.setText("/sdcard/")
  local dl =AlertDialog.Builder(activity)
  dl.setTitle(msg)
  dl.setView(edit)
  dl.setPositiveButton("确定",
  DialogInterface.OnClickListener{
    onClick=function(dialog,which)
      showProcessBar("扫描音乐中，请稍候……")
      getList(edit.getText().toString())
    end
  })
  dl.show()
end
------全局代码------
if tf.exists()==false then--文件列表不存在
  showEditDialog("初次使用软件，设置扫描音乐的路径")
else
 arr= readFile(listpath)
end
----------------------------

--实时更新进度条和时间显示
function updateTime(m,s)
  if m<10 then m="0"..m end
  if s<10 then s="0"..s end
  tv_startTime.setText(m..":"..s)
  pb_time.setProgress(mp.getCurrentPosition())
end

--计时器代码
function _run(m,s)
  function run()

    s=s+1
    if(s==60) then
      m=m+1
      s=0
    end
    call("updateTime",m,s)
  end
end

--上一曲
function on_pre(v)
  if(curIdx>0) then
    curIdx=curIdx-1
    play(mp,arr.get(curIdx))
    local tt=string.gsub(File(arr.get(curIdx)).getName(),".mp3$","")--偷懒一下
    tv_title.setText(tt)
  end
end

--下一曲
function on_next(v)
  if(curIdx<arr.size()-1) then
    if curIdx==0 and not mp.isPlaying() then
      play(mp,arr.get(0))
      local tt=string.gsub(File(arr.get(0)).getName(),".mp3$","")--偷懒一下
      tv_title.setText(tt)
    else
      curIdx=curIdx+1
      play(mp,arr.get(curIdx))
      local tt=string.gsub(File(arr.get(curIdx)).getName(),".mp3$","")--偷懒一下
      tv_title.setText(tt)
    end
  end
end

--设置mediaPlayer播放结束时的回调函数
mp.setOnCompletionListener(MediaPlayer.OnCompletionListener{
  onCompletion=function(mper)
    --     print("歌曲播放结束")
    pb_time.setProgress(mp.getCurrentPosition())
    t.Enabled=false
    t.stop()
    t=nil
    on_next(nil)
  end})

--时间转换函数
function formatTime(time)
  local min,sec=0,0
  sec=math.floor(time/1000)
  if(sec>60) then
    min=math.floor(sec/60)
    sec=math.floor(sec%60)
  end
  if min<10 then min="0"..min end
  if sec<10 then sec="0"..sec end
  return min..":"..sec
end
--时间设置
function setTime(time)
  local min,sec=0,0
  sec=math.floor(time/1000)
  if(sec>60) then
    min=math.floor(sec/60)
    sec=math.floor(sec%60)
  end

  return min,sec
end
--歌曲开始播放
mp.setOnPreparedListener(MediaPlayer.OnPreparedListener{
  onPrepared=function(mper)
    dur=mper.getDuration()--获取歌曲的时常
    pb_time.setMax(dur)
    local tt=formatTime(dur)
    tv_startTime.setText("00:00")
    tv_endTime.setText(tt)
    bn_pause.setText("■")
    min,sec=0,0
    if t~=nil then --计时器不为空就停止
      t.Enabled=false
      t.stop()
      t=nil
    end
    --歌曲开始播放又计时
    t=timer(_run,0,1000,min,sec)
    t.Enabled=true
  end})

--按下暂停时发生
function on_pause(v)
  if(mp.isPlaying()) then
    mp.pause()
    bn_pause.setText("▲")
    if(t~=nil) then
      t.Enabled=false
    end
  else
    if(t~=nil) then--如果为空那就是播放完了的情况
      mp.start()
      bn_pause.setText("■")
      t.Enabled=true
    end
  end
end

--按下"列表"按钮
function on_playlist(v)
  local f=File(String(listpath))
  local isExist= f.exists()
  if(isExist==true) then
    showList(listpath,mp)
  else
    print("列表文件不存在，请重新获取")
    end
  end
  
function on_Menu(v)
  local items={"更新列表","关于","退出"}
  local ad= AlertDialog.Builder(activity)
  ad.setTitle("菜单")
  ad.setItems(String(items)
  ,DialogInterface.OnClickListener{
    onClick=function(dialog,which)
      if which==0 then
        showEditDialog("输入路径以重新扫描")
      elseif which==1 then
        print("落叶似秋制作，无版权，修改请注明原作者\n20170316更新：优化文件扫描器，更快速的扫描")
      elseif which==2 then
        if t~=nil then
          t.stop()
        end
        mp.stop()
        mp.release()--释放资源
        activity.finish()
      end--判断选了哪项的if
    end--onClick
  })
  ad.setNegativeButton( "取消", nil)
  ad= ad.create()
  ad.show()
end

function onKeyDown(code,event)
  if (code== KeyEvent.KEYCODE_BACK)then
    --并不会发生什么...
    if t~=nil then
      t.stop()
    end
    mp.stop()
    mp.release()--释放资源
  end
end

activity.setContentView(loadlayout(main))
back.setImageBitmap(loadbitmap("back.png"))


--进度跳转
pb_time.setOnSeekBarChangeListener(
SeekBar.OnSeekBarChangeListener{
  onStopTrackingTouch=function(bar)
    if mp.isPlaying() then
      local cur=bar.getProgress()
      local tt=formatTime(cur)
      min,sec=setTime(cur)
      tv_startTime.setText(tt)
      mp.seekTo(cur)
      if t~=nil then --计时器不为空就停止
        t.Enabled=false
        t.stop()
        t=nil
      end
      --重新计时
      t=timer(_run,0,1000,min,sec)
      t.Enabled=true
    end

  end})