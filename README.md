<div align="center">

<h1 align="center">OpenZxicEditor</h1>

**一个 POSIX 兼容的 ufiStudio ZXIC-RomKit 开源分支**

</div>

---

## 简介

一键解包和打包 zxic 编程器固件的工具。

附带 MTD 分区的拆分和合并功能。

## 兼容性

已确认在以下系统环境中可使用：

#### Ubuntu

- 22.04 及更高版本请直接使用`installers/install_apt.sh`完成安装
- 低于 22.04 的版本可能还需手动安装`lua5.4` `python3-pip`和`jefferson`

#### Debian

- 12 及更高版本请直接使用`installers/install_apt.sh`完成安装
- 11 版本还需手动安装`jefferson`
- 低于 11 的版本还需手动安装`lua5.4`

## 使用方法

### 一键解包（新功能）

```shell
./dismantle-image <image-path.bin>
```

把编程器固件拆分为分区文件并解包。

解包后的文件会放在名称以`z.`开头的工程文件夹中。

> [!NOTE]
> 编程器固件拆分依赖 mtdcut 组件，但它不开源，因此属于 nonfree 组件。<br>
> OpenZxicEditor 已取得分发权并默认附带。如果您反感此行为，请自行将其删除。

### 分区解包

```shell
./unpack-mtd <project-path/>?
```

解包现有工程文件夹里的各分区。

需要先运行 dismantle-image 或者将工程文件夹复制到同目录，再运行工具。

如果未通过参数输入工程文件夹路径，则会使用默认值`MTDs`。

### 分区打包

```shell
./repack-mtd <project-path/>?
```

打包现有工程文件夹里被解包的各分区。新生成的分区文件以`_new`结尾。

解包数据与 Windows 中的 ufiStudio 不通用，请在 Linux/Unix 环境中生成`*_unpacked`解包文件夹。

如果未通过参数输入工程文件夹路径，则会使用默认值`MTDs`。

> [!NOTE]
> 如果打包 jffs2 分区时遇到`Permission denied`问题，可以使用 sudo 提权运行./repack-mtd 。

### 分区合并

```shell
./merge-mtd <project-path/>?
```

只将各 MTD 分区合并为编程器固件。

支持导入 ufiStudio 解包生成的带 json 的工程文件夹，也支持 ADB 提取的纯 MTDs（mtd`%d`）。

如果未通过参数输入工程文件夹路径，则会使用默认值`MTDs`。

### 一键打包

```shell
./rebuild-image <project-path/>?
```

打包所有解包的分区，并重新整合成编程器固件。

解包数据与 Windows 中的 ufiStudio 不通用，请在 Linux/Unix 环境中生成`*_unpacked`解包文件夹。

如果未通过参数输入工程文件夹路径，则会使用默认值`MTDs`。

打包后将在对应工程文件夹中生成新的编程器映像文件`full_new.bin`。

## 注意事项

1. 程序主要是为了方便自己使用而写的，所以可能会有一些问题，欢迎提出建议。
2. 已经注意了空格和中文路径的问题，但如果出现错误可以尝试将文件放到简单路径下再试。
3. 软件会解包所有受支持的分区类型。如果某分区不需要修改，那么建议删除相应的解包文件夹，合并时将会自动使用原版。
4. 此版本提供了实验性的`jffs2`文件系统支持，默认不使用。如果需要，请创建文件`__lib__\--enable-jffs2`。
5. 如需查看分区解包时的详细信息(日志)，请创建文件`__lib__\--enable-log`。
