defmodule SendGrid.TransactionalTemplates.Test do
  @moduledoc """
    Module to test Transactional Template CRUD. Not this module requires that api key has read/write/update/delete permissions for templates and versions.
  """
  use ExUnit.Case, async: true
  doctest SendGrid.Templates, import: true
  doctest SendGrid.Template, import: true
  doctest SendGrid.Template.Version, import: true
  require Logger
  alias SendGrid.Templates
  alias SendGrid.Template
  alias SendGrid.Template.Versions
  alias SendGrid.Template.Version

  @tag :templates
  test "fetch templates" do
    actual = Templates.list()
    assert is_list(actual)
  end

  @tag :templates
  test "template crud" do
    # Note Better fixture management needed to avoid orphaned elements.
    # Note I'm not a fan of multi asserts per test but it simplifies fixture management for now.

    test_run = :os.system_time(:millisecond)
    name = "TestTemplate#{test_run}"
    updated_name = "UpdatedTemplateName#{test_run}"

    # Create Template
    new_template = Templates.create(%Template{name: name})
    assert new_template.id != nil

    try do
      # Update Template
      _updated_template = Templates.update(%Template{new_template| name: updated_name})

      # Read Template
      read_template = Templates.get(new_template.id)
      assert read_template.name == updated_name
    after
      # Delete Template
      Templates.delete(new_template)
      {:error, _} = Templates.get(new_template.id)
    end
  end

  @tag :templates
  test "template.version crud" do
    # Note Better fixture management needed to avoid orphaned elements.
    # Note I'm not a fan of multi asserts per test but it simplifies fixture management for now.

    test_run = :os.system_time(:millisecond)
    name = "TestTemplate#{test_run}"
    test_version_name = "TestVersion#{test_run}"
    updated_test_version = "TestVersionUpdated#{test_run}"

    # Create Template
    new_template = Templates.create(%Template{name: name})
    template_id = new_template.id
    assert template_id != nil

    try do
      # Create Version
      new_version = Versions.create(%Version{name: test_version_name, template_id: template_id, subject: "Hello World", html_content: "Hello", plain_content: "Hello txt"})
      assert new_version.id != nil

      # Update Version
      updated_version = Versions.update(%Version{new_version| name: updated_test_version})

      # Get Version
      read_version = Versions.get(updated_version.template_id, updated_version.id)
      assert read_version.name == updated_test_version

      # Delete Version & Confirm
      delete_version = Versions.delete(read_version)
      assert delete_version == :ok
      {:error, _details} = Versions.get(new_version.template_id, new_version.id)
    after
      Templates.delete(new_template)
    end

    {:error, _} = Templates.get(new_template.id)
  end


end
