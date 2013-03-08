    Thanks for using ims-Gtalk !

    1.使用 gtalk账户 登录 ，gtalk使用的就是 gmail注册账号。

    2.登录成功后，会进入 主界面；失败则 在登录界面提示 登录失败。
	
	登录目前支持 以XMPP协议的5222端口 登录（默认的）；如果5222端口不行（很可能公司屏蔽了高端口），会尝试走     
     TCP443端口 去登录（这个一般比较慢，需要1-2分钟，pc上的gtalk也如此。）

        在登录loading状态的时候，可以 输入 “Stop” 来 cancel此次登录；或者 "return"键 退出这次登录。

        一般登录失败的原因有：（1）网络不通 （2）账号或者密码有误  （3）有可能 gtalk随机启动的daemon服务程序挂
    
     了，这个有时候偶尔会挂，可以通过ps来查看 是否有 IMS_Modules/gtalk/gtalk 进程存在。

    3.主界面，其中左边是功能menu，右边 是 好友 列表
   
    4.menu中包括：

          change my status:    可以修改 自己的 状态 以及 个性签名。
          options         :    提供了更多选项设置。
          Buddy list      :    可以 添加新的friend, 可以 删除 已有的 friend 。
          Logout          :    注销此次登录 。如果不logout，直接return的话，gtalk会保持登录状态。


        
      详细介绍如下；

        4.1 change my status

            点击menu，弹出2级menu， 第一个是修改 status的，按enter弹出三种状态，availabe/busy/idle;
                                    第二个是 修改 状态签名的，默认的是watching tv，按enter进入小键盘设置自己的信息					     签名。

	4.2 options
 
            点击menu，弹出 2级menu，分别有六个menu。

            4.2.1 set receive dir:USB->gtalk/

              点击该menu，会弹出一个小的file browser menu，默认的会 进入 已经设定的接收路径下；

            如果没有设定，则进入根目录。
        
              点击浏览 所需要的 分区 路径，输入 “Edit”即 大写“E”，即可选中 当前focus的目录为 默认

            接受路径，同时关闭 窗口，回到主界面。
               
	    4.2.2 Show offline friend:Yes/No

               设置是否显示  离线好友。 

               如果当前显示 Show offline friend:Yes，则表明 当前状态是 不show离线好友的，按下enter后

            会切换到显示 离线好友；反之亦然。

            4.2.3 Receive files in:USB->gtalk/

               点击该menu，查看 默认存放目录，如果没有，则提示： unable to service request.

	    4.2.4 Browse USB->gtalk/

              点击menu，直接 切换到 Dvdplayer的 File Manager的 Browser 下。

            4.2.5 view history of file shares

	      点击，查看 接收过的文件 历史记录信息。
            
	    4.2.6 view current file shares

               点击该menu，进入 正在 接收 或 发送 的 文件列表 信息。

              如果要 cancel某个 传输进程，只要 focus 它，然后 输入“Edit”，弹出 confirm menu，选择 yes，即可。

              如果要 查看 某个 传输进程的 包含的详细 文件信息， 对focus的 进程，输入 “enter”，即可弹出 小menu，

             show出，详细文件信息；然后 输入 “enter” 或者 “return”，即可关闭 该小menu。             

	4.3 Buddy list
            
	    4.3.1 Add a buddy

 		添加新的好友，点击进入 小键盘，可以输入 好友id，注：一般全名为 id@gmail.com，后缀是统一的，所以

            只需要输入 前缀 id，即可。

            4.3.2 remove a buddy
              
                点击进入简单的好友列表， 点击 focus的好友，即可弹出confirm界面，确认是否删除该好友。


        4.4  >>logout                

	       注销登录 ，回到login界面。 如果 不 logout，返回到ims guide界面，则保留登录状态；再进入gtalk的话，则	           不需要重新登录，直接进入 gtalk 主界面。

    5. 好友 item。

        好友 状态一般分为 在线，忙碌，idle，离线，以及 ？（表明 别人invite u成为好友 或者 你invite别人成为好友）

        右侧的好友列表，可以上下来 切换 focus到哪个好友上面。

        右上角的 图标:num 表明 目前有几个好友 有新的未读消息。

        当focus到某个好友时，输入"Edit"，可以弹出 是否删除该好友的 confirm界面；当然对于 ？状态的，别人对自己提出
     的好友申请   请求，按 ”Edit“则，弹出 是否 接受对方邀请的 confirm界面。



        选择 某个好友，点击该item，则 进入 friend menu。

        目前留有 七个按钮:"input msg"  "send msg"   "sendfiles"  "receive files"   "sharingList" "past chats" 
    "leave back" 。

        
        5.1 input msg ,send msg

            这个主要是为了发消息 提供的两个键，前者输入信息，后者点击发送。发送后在界面上面的对话框，会显示及时聊
	天信息。

            即时消息的界面，最新来的消息是显示在最上面的；对于同一对话界面，如果消息很多了，会支持分页，按上下键可
        以查看，目前设定只显示最近20条; 消息的显示格式是，id(time):msg， 这里的time，因为daemon那边其实没有提供，        所以是 以显示这消息的时间记录的，其实按照pc的gtalk，time是不显示的。
       
            注：暂不支持 给离线好友发信息。

        5.2  "sendfiles"

             点击，进入 文件browser 页面，目前 只支持 U盘 目录。

             gtalk目前支持 单个文件，单个文件夹，多个文件，多个文件夹 的发送。
  
             只要选择 所需发送的 文件/文件夹，输入"Edit"，即可选中，后面会有 勾选的图形提示 该file已经被选中；再次	  
          输入“edit”可以取消选中。

             选择完毕后，输入“Play”，即大写“S”键， 即可发送 已经选中的所有file，同时 界面，进入sharing list界面。

             输入“Pause”，即大写“Z”键， 也可以 进入 Sharing list界面。

	5.3  "receive files"

	     如上，进入查看 默认的接收文件目录。  目前，接收文件，对用户暂时还没有任何提示，默认是 只要 好友发文件        
            ，自动接受该文件。

        5.4   "sharingList"

             如上，进入 sharling list menu。

        5.5   "past chats"

              查看 历史聊天记录。暂时由于空间限制，只保留最近的200条聊天记录。

        5.6   "leave back"

             离开该menu。



 







  ......to be continued!




 


           


          