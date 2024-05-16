<div align="center">

<h1 align="center">OpenZfwEdit</h1>

**一个 POSIX 兼容的 ufiStudio ZXIC-RomKit 开源分支**

</div>

---

## 简介

可以一键解包和打包 zxic 编程器固件的工具。

附带 MTD 分区的拆分和合并功能。

## 使用方法

### 一键解包（暂不可用）
```shell
dismantle-image <image-path.bin>
```
把编程器固件拆分为分区文件并解包。

解包后的文件会放在名称以`z.`开头的工程文件夹中。

> [!NOTE]
> 编程器固件拆分依赖mtdcut组件，但它不开源，所以本功能暂不可用。正在与ufiStudio开发者协商如何解决这个问题。

### 分区解包
```shell
unpack-mtd <project-path.tree>
```
解包现有工程文件夹里的各分区。

目前您可以使用Windows系统中的ufiStudio创建工程文件夹，删除所有解包内容(不通用)，然后复制到Linux/Unix系统中使用此工具解包。

### 分区打包
```shell
repack-mtd <project-path.tree>
```
打包现有工程文件夹里被解包的各分区。新生成的分区文件以`_new`结尾。

解包数据与Windows中的ufiStudio不通用，只能重新打包Linux/Unix下解包的文件夹。

### 分区合并
```shell
merge-mtd <project-path.tree>
```
只将各 MTD 分区合并为编程器固件。

支持导入ufiStudio解包生成的带json的工程文件夹，也支持ADB提取的纯 MTDs（mtd`%d`）。

### 一键打包
```shell
rebuild-image <project-path.tree>
```
打包所有解包的分区，并重新整合成编程器固件。

打包后将在对应工程文件夹中生成新的编程器映像文件`full_new.bin`。

## 注意事项

1. 程序主要是为了方便自己使用而写的，所以可能会有一些问题，欢迎提出建议。
2. 已经注意了空格和中文路径的问题，但如果出现错误可以尝试将文件放到简单路径下再试。
3. 软件会解包所有受支持的分区类型。如果某分区不需要修改，那么建议删除相应的解包文件夹，合并时将会自动使用原版。
4. 此版本提供了实验性的`jffs2`文件系统支持，默认不使用。如果需要，请创建文件`__lib__\--enable-jffs2`。
