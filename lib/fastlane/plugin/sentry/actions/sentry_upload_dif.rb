module Fastlane
  module Actions
    class SentryUploadDifAction < Action
      def self.run(params)
        require 'shellwords'

        Helper::SentryHelper.check_sentry_cli!
        Helper::SentryConfig.parse_api_params(params)

        # force_foreground
        # include_sources
        # wait
        # upload_symbol_maps

        command = [
          "sentry-cli",
          "upload-dif"
        ]
        command.push('--paths').push(params[:paths]) unless params[:paths].nil?
        command.push('--types').push(params[:types]) unless params[:types].nil?
        command.push('--no_unwind') unless params[:no_unwind].nil?
        command.push('--no_debug') unless params[:no_debug].nil?
        command.push('--no_sources') unless params[:no_sources].nil?
        command.push('--ids').push(params[:ids]) unless params[:ids].nil?
        command.push('--require_all') unless params[:require_all].nil?
        command.push('--symbol_maps').push(params[:symbol_maps]) unless params[:symbol_maps].nil?
        command.push('--derived_data') unless params[:derived_data].nil?
        command.push('--no_zips') unless params[:no_zips].nil?
        command.push('--info_plist').push(params[:info_plist]) unless params[:info_plist].nil?
        command.push('--no_reprocessing') unless params[:no_reprocessing].nil?
        command.push('--force_foreground') unless params[:force_foreground].nil?

        Helper::SentryHelper.call_sentry_cli(command)
        UI.success("Successfully ran upload-dif")
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Upload debugging information files."
      end

      def self.details
        [
          "Files can be uploaded using the upload-dif command. This command will scan a given folder recursively for files and upload them to Sentry.",
          "See https://docs.sentry.io/platforms/native/data-management/debug-files/upload/ for more information."
        ].join(" ")
      end

      def self.available_options
        Helper::SentryConfig.common_api_config_items + [
          FastlaneCore::ConfigItem.new(key: :paths,
                                       description: "A path to search recursively for symbol files"),
          FastlaneCore::ConfigItem.new(key: :types,
                                       short_option: "-t",
                                       description: "Only consider debug information files of the given \
                                       type.  By default, all types are considered",
                                       optional: true,
                                       verify_block: proc do |value|
                                        UI.user_error! "Invalid value '#{value}'" unless ['dsym', 'elf', 'breakpad', 'pdb', 'pe', 'sourcebundle', 'bcsymbolmap'].include? value
                                       end),
          FastlaneCore::ConfigItem.new(key: :no_unwind,
                                       description: "Do not scan for stack unwinding information. Specify \
                                       this flag for builds with disabled FPO, or when \
                                       stackwalking occurs on the device. This usually \
                                       excludes executables and dynamic libraries. They might \
                                       still be uploaded, if they contain additional \
                                       processable information (see other flags)",
                                       is_string: false,
                                       optional: true),
            FastlaneCore::ConfigItem.new(key: :no_debug,
                                       description: "Do not scan for debugging information. This will \
                                       usually exclude debug companion files. They might \
                                       still be uploaded, if they contain additional \
                                       processable information (see other flags)",
                                       conflicting_options: [:no_unwind],
                                       is_string: false,
                                       optional: true),
            FastlaneCore::ConfigItem.new(key: :no_sources,
                                       description: "Do not scan for source information. This will \
                                       usually exclude source bundle files. They might \
                                       still be uploaded, if they contain additional \
                                       processable information (see other flags)",
                                       is_string: false,
                                       optional: true),
            FastlaneCore::ConfigItem.new(key: :ids,
                                       description: "Search for specific debug identifiers",
                                       optional: true),
            FastlaneCore::ConfigItem.new(key: :require_all,
                                       description: "Errors if not all identifiers specified with --id could be found",
                                       is_string: false,
                                       optional: true),
            FastlaneCore::ConfigItem.new(key: :symbol_maps,
                                       description: "Optional path to BCSymbolMap files which are used to \
                                       resolve hidden symbols in dSYM files downloaded from \
                                       iTunes Connect. This requires the dsymutil tool to be \
                                       available",
                                       optional: true),
            FastlaneCore::ConfigItem.new(key: :derived_data,
                                       description: "Search for debug symbols in Xcode's derived data",
                                       is_string: false,
                                       optional: true),
            FastlaneCore::ConfigItem.new(key: :no_zips,
                                       description: "Do not search in ZIP files",
                                       is_string: false,
                                       optional: true),
            FastlaneCore::ConfigItem.new(key: :info_plist,
                                       description: "Optional path to the Info.plist.{n}We will try to find this \
                                       automatically if run from Xcode.  Providing this information \
                                       will associate the debug symbols with a specific ITC application \
                                       and build in Sentry.  Note that if you provide the plist \
                                       explicitly it must already be processed",
                                       optional: true),
            FastlaneCore::ConfigItem.new(key: :no_reprocessing,
                                       description: "Do not trigger reprocessing after uploading",
                                       is_string: false,
                                       optional: true),
            FastlaneCore::ConfigItem.new(key: :force_foreground,
                                       description: "Wait for the process to finish.{n}\
                                       By default, the upload process will detach and continue in the \
                                       background when triggered from Xcode.  When an error happens, \
                                       a dialog is shown.  If this parameter is passed Xcode will wait \
                                       for the process to finish before the build finishes and output \
                                       will be shown in the Xcode build output",
                                       is_string: false,
                                       optional: true),
        ]
      end

      def self.return_value
        nil
      end

      def self.authors
        ["denrase"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end