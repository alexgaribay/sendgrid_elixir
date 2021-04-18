defmodule SendGrid.Templates.Test do
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
  alias SendGrid.DynamicTemplate
  alias SendGrid.LegacyTemplate

  @tag :templates
  test "generations query param patch" do
    options = [query: [generations: [:legacy,:dynamic]]]
    sut = Templates.patch_options(options)
    assert sut == [query: [generations: "legacy,dynamic"]]
  end

  @tag :templates
  test "fetch templates" do
    test_run = :os.system_time(:millisecond)
    fixture_a = Templates.create(%LegacyTemplate{name: "TestTemplate#{test_run}a"})
    fixture_b = Templates.create(%DynamicTemplate{name: "TestTemplate#{test_run}b"})
    try do
      actual = Templates.list(query: [page_size: 1])
      assert %Templates{} = actual
      assert length(actual.templates) == 1
      assert is_bitstring(actual.metadata.self)
      assert actual.metadata.count > 1
    after
      Templates.delete(fixture_a)
      Templates.delete(fixture_b)
    end
  end

  @tag :templates
  test "paginated fetch templates" do
    test_run = :os.system_time(:millisecond)
    fixture_a = Templates.create(%LegacyTemplate{name: "TestTemplate#{test_run}a"})
    fixture_b = Templates.create(%DynamicTemplate{name: "TestTemplate#{test_run}b"})
    try do
      actual = Templates.list(query: [page_size: 1])
      assert %Templates{} = actual
      assert length(actual.templates) == 1
      assert is_bitstring(actual.metadata.self)
      assert actual.metadata.count > 1

      next = Templates.next(actual)
      assert %Templates{} = actual
      assert length(next.templates) == 1
      assert next.metadata.self != actual.metadata.self
      assert actual.metadata.count > 1
    after
      Templates.delete(fixture_a)
      Templates.delete(fixture_b)
    end
  end


  @tag :templates
  test "template crud" do
    # Note Better fixture management needed to avoid orphaned elements.
    # Note I'm not a fan of multi asserts per test but it simplifies fixture management for now.

    test_run = :os.system_time(:millisecond)
    name = "TestTemplate#{test_run}"
    updated_name = "UpdatedTemplateName#{test_run}"

    # Create Template
    new_template = Templates.create(%DynamicTemplate{name: name})
    assert new_template.id != nil

    try do
      # Update Template
      _updated_template = Templates.update(%DynamicTemplate{new_template| name: updated_name})

      # Read Template
      read_template = Templates.get(new_template.id)
      assert read_template.name == updated_name
    after
      # Delete Template
      Templates.delete(new_template)
    end
    {:error, _} = Templates.get(new_template.id)
  end

  @tag :templates
  test "template.version crud (legacy)" do
    # Note Better fixture management needed to avoid orphaned elements.
    # Note I'm not a fan of multi asserts per test but it simplifies fixture management for now.

    test_run = :os.system_time(:millisecond)
    name = "TestTemplate#{test_run}"
    test_version_name = "TestVersion#{test_run}"
    updated_test_version = "TestVersionUpdated#{test_run}"

    # Create Template
    new_template = Templates.create(%LegacyTemplate{name: name})
    template_id = new_template.id
    assert template_id != nil

    try do
      # Create Version
      new_version = Versions.create(%Version{name: test_version_name, template_id: template_id, subject: "Hello World", html_content: "Hello", plain_content: "Hello txt"})
      assert new_version.id != nil

      # Update Version
      updated_version = Versions.update(%Version{new_version| name: updated_test_version, editor: nil})
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


  @tag :templates
  test "template.version crud (dynamic)" do
    # Note Better fixture management needed to avoid orphaned elements.
    # Note I'm not a fan of multi asserts per test but it simplifies fixture management for now.

    test_run = :os.system_time(:millisecond)
    name = "TestTemplate#{test_run}"
    test_version_name = "TestVersion#{test_run}"
    updated_test_version = "TestVersionUpdated#{test_run}"

    # Create Template
    new_template = Templates.create(%DynamicTemplate{name: name})
    template_id = new_template.id
    assert template_id != nil

    try do
      # Create Version
      new_version = Versions.create(%Version{name: test_version_name, template_id: template_id, subject: "Hello World", html_content: "Hello", plain_content: "Hello txt"})
      assert new_version.id != nil

      # Update Version
      updated_version = Versions.update(%Version{new_version| name: updated_test_version, editor: nil})
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
