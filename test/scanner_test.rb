require "test_helper"

module Portfinder
  class ScannerTest < Minitest::Test
    extend Minitest::Spec::DSL

    let(:threaded_ip_scanner) do
    end

    let(:threaded_port_scanner) do
    end

    let(:serial_scanner) do
    end

    def test_assert_scan_can_handle_synchronus_and_asynchronus_scan; end

    def test_assert_log_generates_logger; end

    def test_assert_generate_result_generates_result_in_the_proper_format; end

    def test_assert_report_as_generates_correct_formats; end

    def test_assert_json_report_provides_valid_json_formatting; end

    def test_assert_yml_report_provides_valid_yml_formatting; end
  end
end
