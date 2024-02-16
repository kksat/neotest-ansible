local neotest = {}

---@class neotest.Adapter
---@field name string
neotest.Adapter = {}

function neotest.Adapter.root(dir)
	-- Simplified: Assuming the root is where a specific marker (e.g., ansible.cfg) is found.
	-- This function should be adapted to properly identify your Ansible project root.
	local uv = vim.loop
	while dir do
		if uv.fs_stat(vim.fn.join({ dir, "ansible.cfg" })) then
			return dir
		end
		dir = vim.fn.fnamemodify(dir, ":h")
		if dir == "/" then
			break
		end
	end
	return nil
end

function neotest.Adapter.filter_dir(name, rel_path, root)
	-- Example: Ignore certain directories. Adjust according to your project structure.
	local ignore_dirs = { ".git", "node_modules" }
	for _, ignore in ipairs(ignore_dirs) do
		if name == ignore then
			return false
		end
	end
	return true
end

function neotest.Adapter.is_test_file(file_path)
	return file_path:match("test_.*%.yml$") ~= nil
end

function neotest.Adapter.discover_positions(file_path)
	-- Simplified: Assuming each playbook file is a single test.
	-- You might want to parse the file to discover individual tasks or roles as separate tests.
	return {
		id = file_path,
		type = "file",
		path = file_path,
		children = {},
	}
end

function neotest.Adapter.build_spec(args)
	local run_cmd = { "ansible-playbook", args.tree.id }
	return {
		command = "ansible-playbook",
		-- args = { unpack(run_cmd, 2) },
		-- 	context = {
		-- 		cwd = args.tree.path:match("(.*/)"),
		-- 	},
	}
end

function neotest.Adapter.results(spec, result, tree)
	-- Simplified: This should parse the output from Ansible and map it to test results.
	-- Here we assume success if the command exit code is 0.
	local success = result.code == 0
	local output = result.output or ""
	return {
		[tree.id] = {
			status = success and "passed" or "failed",
			output = output,
		},
	}
end

neotest.Adapter.name = "ansible"

return neotest.Adapter
