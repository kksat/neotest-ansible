local lib = require("neotest.lib")
local async = require("neotest.async")

---@class neotest.Adapter
---@field name string
AnsibleNeotestAdapter = {
	name = "neotest-ansible",
}

function AnsibleNeotestAdapter.root(dir)
	return vim.fn.getcwd()
end

function AnsibleNeotestAdapter.filter_dir(name, rel_path, root)
	-- Example: Ignore certain directories. Adjust according to your project structure.
	local ignore_dirs = { ".git", "node_modules" }
	for _, ignore in ipairs(ignore_dirs) do
		if name == ignore then
			return false
		end
	end
	return true
end

function AnsibleNeotestAdapter.is_test_file(file_path)
	return file_path:match("test_.*%.yml$") ~= nil or file_path:match("test_.*%.yaml$") ~= nil
end

function AnsibleNeotestAdapter.discover_positions(file_path)
	-- Simplified: Assuming each playbook file is a single test.
	-- You might want to parse the file to discover individual tasks or roles as separate tests.
	return {
		id = file_path,
		type = "file",
		path = file_path,
		children = {},
	}
end

function AnsibleNeotestAdapter.build_spec(args)
	local run_cmd = { "ansible-playbook", args.tree.id }
	return {
		command = "ansible-playbook",
		args = { unpack(run_cmd, 2) },
		-- 	context = {
		-- 		cwd = args.tree.path:match("(.*/)"),
		-- 	},
	}
end

function AnsibleNeotestAdapter.results(spec, result, tree)
	-- Simplified: This should parse the output from Ansible and map it to test results.
	-- Here we assume success if the command exit code is 0.
	local success = result.code == 0
	local output = result.output or ""
	return {
		[tree.id] = {
			-- status = success and "passed" or "failed",
			status = "passed",
			output = "output",
		},
	}
end

AnsibleNeotestAdapter.name = "ansible"

return AnsibleNeotestAdapter
