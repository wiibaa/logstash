require "test_utils"
require "logstash/filters/split"

describe LogStash::Filters::Split do
  extend LogStash::RSpec

  describe "default behavior" do
    config <<-CONFIG
      filter {
        split {}
      }
    CONFIG

    sample "one\ntwo" do
      insist { subject.length } == 2
      insist {subject[0].message} == "one"
      insist {subject[1].message} == "two"
    end

    sample "\nthree\nfour\n" do
      insist { subject.length } == 2
      insist {subject[0].message} == "three"
      insist {subject[1].message} == "four"
    end

    sample "five" do
      insist {subject.message} == "five"
    end
  end

  describe "when field is set" do
    config <<-CONFIG
      filter {
        split {
          field => "@source"
        }
      }
    CONFIG

    sample({"@source" => "one\ntwo", "@message" => "foo"}) do
      insist { subject.length } == 2
      insist {subject[0].source } == "one"
      insist {subject[0].message } == "foo"
      insist {subject[1].source } == "two"
      insist {subject[1].message } == "foo"
    end

    sample ({"@source" => "\nthree\nfour\n", "@message" => "foo"})do
      insist { subject.length } == 2
      insist {subject[0].source } == "three"
      insist {subject[0].message } == "foo"
      insist {subject[1].source } == "four"
      insist {subject[1].message } == "foo"
    end

    sample ({"@source" => "five", "@message" => "foo"}) do
      insist {subject.source} == "five"
      insist {subject.message} == "foo"
    end
  end

  describe "when terminator is set" do
    config <<-CONFIG
      filter {
        split {
          terminator => "o"
        }
      }
    CONFIG

    sample "hello world" do
      insist { subject.length } == 3
      insist {subject[0].message} == "hell"
      insist {subject[1].message} == " w"
      insist {subject[2].message} == "rld"

    end

    sample "one + two" do
      insist {subject.message} == "ne + tw"
    end

    sample "is four" do
      insist { subject.length } == 2
      insist {subject[0].message} == "is f"
      insist {subject[1].message} == "ur"
    end

    sample "five" do
      insist {subject.message} == "five"
    end
  end
end
