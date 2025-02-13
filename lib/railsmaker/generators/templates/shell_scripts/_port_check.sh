check_port() {
    if lsof -i ":$1" >/dev/null 2>&1; then
        echo "Error: Port $1 is already in use"
        return 1
    fi
    return 0
}

check_required_ports() {
    local ports="$1"
    local ports_in_use=""

    echo "🔍 Checking if required ports are available..."

    for port in $ports; do
        if ! check_port "$port"; then
            ports_in_use="$ports_in_use $port"
        fi
    done

    if [ ! -z "$ports_in_use" ]; then
        echo "❌ Cannot proceed. The following ports are already in use:$ports_in_use"
        echo "Please free up these ports before continuing"
        exit 1
    fi

    echo "✅ All required ports are available"
} 