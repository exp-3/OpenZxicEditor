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

### 一键解包

```shell
./dismantle-image <image-path.bin>
```

把编程器固件拆分为分区文件并解包。

解包后的文件会放在名称以`z.`开头的工程文件夹中。

> [!NOTE]
> 编程器固件拆分依赖 mtdcut ，但它不开源，因此属于 nonfree 组件。<br>
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

打包后将在对应工程文件夹中生成新的镜像文件`full_new.bin`，可直接使用烧录器写入闪存。

## 注意事项

1. 此程序尚不完善，可能存在一些问题，欢迎提出建议。
2. 开发时已留意了空格和中文路径的问题，但如果遇到迷惑 bug 可以尝试将文件放到简单路径下再试。
3. 软件会解包所有受支持的分区类型。如果某分区不需要修改，那么建议删除相应的解包文件夹，合并时将会自动使用原版。
4. 如需查看分区解包/打包时的详细信息(日志)，请创建文件`__lib__\--enable-log`。

## 使用须知

1. 禁止将此项目用于任何非法和不道德的行为，所造成的任何后果由使用者承担。<br/>
   且不建议将此项目用于商业用途，如遇纠纷及其他不良后果请贩卖者自行承担。
2. 如需二次开发，请遵守 AGPLv3 协议 (详见 开源许可.md)，并明确标注版权信息和出处。<br/>
   如果出于规避 AGPLv3 协议等目的需要仿制/重制本项目，请遵循白盒净室开发流程，并注明参考资料出处。

## 关于项目

1. 本项目的开发目的是研究 ZXIC 路由的固件格式，并希望为爱好者学习提供便利。
2. 目前仅确认支持 ZX7520v3 芯片平台的固件，其他固件格式可能存在差异，请自行研究。
3. ufiStudio 系列软件 (含 OpenZxicEditor) 现已完全由 MiFi~Lab 独立维护。即日起不再通过 ufitech 或 uficlub 发布。
4. 欢迎各位用户和开发者提出建议，协助完善本项目。
