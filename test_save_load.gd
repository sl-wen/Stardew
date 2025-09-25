#!/usr/bin/env -S godot --headless
extends SceneTree

func _init():
    print("开始测试存档功能...")

    # 测试SaveManager._save()方法
    print("测试SaveManager._save()...")
    SaveManager._save()
    print("SaveManager._save() 执行完成")

    # 测试SaveManager._load()方法
    print("测试SaveManager._load()...")
    SaveManager._load()
    print("SaveManager._load() 执行完成")

    print("测试完成")
    quit()