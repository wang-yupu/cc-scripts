import argparse


class ArgumentParser:
    def __init__(self):
        parser = argparse.ArgumentParser(
            description="脚本构建工具"
        )

        parser.add_argument(
            "script",
            help="脚本名，使用`all`会对仓库中所有脚本进行生成"
        )

        parser.add_argument(
            "--run-after-build",
            action="store_true",
            help="启用after-build"
        )

        parser.add_argument(
            "--skip-enviroment-check",
            action="store_true",
            help="不检查工具链上的工具"
        )

        parser.add_argument(
            "--skip-lua-dependencies-check",
            action="store_true",
            help="不检查Lua依赖"
        )

        parser.add_argument(
            "--disable-bundle",
            action="store_true",
            help="不捆绑Lua文件"
        )

        parser.add_argument(
            "--after-build-id",
            type=int,
            metavar="ID",
            help="若启用after-build，会将脚本写入对应计算机"
        )

        parser.add_argument(
            "--minify",
            action="store_true",
            help="简化生成的代码"
        )

        # 构建模式
        mode_group = parser.add_mutually_exclusive_group()
        mode_group.add_argument(
            "--release",
            action="store_true",
            help="生产模式"
        )
        mode_group.add_argument(
            "--debug",
            action="store_true",
            help="调试模式，自动构建"
        )
        mode_group.add_argument(
            "--installer",
            action="store_true",
            help="生产模式并生成安装器"
        )

        args = parser.parse_args()
        self.script = args.script
        self.runAfterBuild = args.run_after_build
        self.afterBuildID = args.after_build_id
        self.release = args.release
        self.debug = args.debug
        self.installer = args.installer
        self.skipEnviromentCheck = args.skip_enviroment_check
        self.skipLuaDependenciesCheck = args.skip_lua_dependencies_check
        self.minify = args.minify
        self.disableBundle = args.disable_bundle

    def __repr__(self):
        """便于调试时打印配置"""
        return f'''<
脚本: {self.script}
调试模式: {self.debug}
生产模式: {self.release}
打包安装器: {self.installer}
运行after-build: {self.runAfterBuild}
复制到计算机: {self.afterBuildID}
跳过Lua依赖检查: {self.skipLuaDependenciesCheck}
跳过工具链工具检查: {self.skipEnviromentCheck}
>'''
