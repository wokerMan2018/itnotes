- 自动对齐（格式化排版）

  - 选中内容对齐：可视模式或鼠标选中内容后按下`=`
  - 全文自动对齐：正常模式按下`gg=G`


- 删除

  - 全文删除`ggdG`
  - 从当前位置删除到行首`d0`
  - 从当前位置删除到行尾`d$`或`D`


- 变量名自动补全

  - <kbd>ctrl</kbd> <kbd>n</kbd>
  - <kbd>ctrl</kbd> <kbd>p</kbd>

- 排序`:sort`

- 临时执行命令`:!command`

  - 普通用户编辑时临时启用sudo保存文件`:!w sudo tee %`

    `%`是vim当中一个只读寄存器的名字，该寄存器总保存着当前编辑文件的文件路径。

- 从缓冲区重新载入`:e`

  - 放弃当前更改从缓冲区重新载入`:!e`

- 多行编辑
  1. `ctrl`-`v`配合方向键/定位键等（如`G`、`$`）选中区块

  2. 选择不同的修改模式

     - 替换：
       1. 输入`r`
       2. 输入替换内容后直接完成替换

     - 插入：
       1. 前插入`I` / 后插入`A`
       2. 输入要插入的内容
       3. `esc`完成编辑，再次`esc`将在所有行完成插入。

- 查找替换
  - 全文件替换

    ```shell
    %s/thisword/thatword/  #替换所有行中的thisword为thatwork
    1,$s/thisword/thatword/  #替换所有行中的thisword为thatwork
    ```

  - 指定行替换

    ```shell
    1,25s/thisword/thatword/  #替换1到25行中的thisword为thatwork
    ```

- 复制内容到剪切板  `"y`

  需要vim支持clipboard功能，执行`vim --version|grep +clipboar`查看是否支持。vim将内容存储在寄存器中

  - `:reg` 查看所有寄存器
  - `""`  最进依次修改的内容
  - `“<n>`  最近第n次修改的内容
