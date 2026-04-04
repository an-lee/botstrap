#!/usr/bin/env node
import { copyFileSync, mkdirSync } from 'node:fs'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'

const root = join(dirname(fileURLToPath(import.meta.url)), '..')
const publicDir = join(root, 'docs', 'public')

mkdirSync(publicDir, { recursive: true })
copyFileSync(join(root, 'boot.sh'), join(publicDir, 'install'))
copyFileSync(join(root, 'boot.ps1'), join(publicDir, 'install.ps1'))
