package com.mycir.termuxrunner

import android.app.Activity
import android.content.Intent
import android.os.Bundle

class MainActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val intent = Intent().apply {
            setClassName(
                "com.termux",
                "com.termux.app.RunCommandService"
            )

            action = "com.termux.RUN_COMMAND"

            putExtra(
                "com.termux.RUN_COMMAND_PATH",
                "/data/data/com.termux/files/home/.shortcuts/tasks/termux-runner.sh"
            )

            putExtra(
                "com.termux.RUN_COMMAND_ARGUMENTS",
                emptyArray<String>()
            )

            putExtra(
                "com.termux.RUN_COMMAND_WORKDIR",
                "/data/data/com.termux/files/home"
            )

            putExtra(
                "com.termux.RUN_COMMAND_BACKGROUND",
                true
            )
        }

        startService(intent)
        finish()
    }
}
