module LdapMapper
	class Error < StandardError; end

	class RecordNotFound < Error; end
	
	class ConnectionError < Error; end
	
	class OperationError < Error; end
end