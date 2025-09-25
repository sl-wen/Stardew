#!/usr/bin/env -S godot --headless
extends SceneTree

func _init():
    print("开始测试新建游戏功能...")

    # 测试清除存档功能
    print("测试SaveManager.clear_save_data()...")
    SaveManager.clear_save_data()
    print("清除存档完成")

    # 测试新建游戏功能
    print("测试SaveManager.new_game()...")
    SaveManager.new_game()
    print("新建游戏完成")

    print("测试完成")
    quit()