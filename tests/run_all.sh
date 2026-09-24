#!/data/data/com.termux/files/usr/bin/bash

echo "================================"
echo "  Anime Academy — все тесты"
echo "================================"
echo ""

total_passed=0
total_failed=0

run_test() {
	local name="$1"
	local file="$2"
	echo "--- $name ---"
	if lua "$file"; then
		total_passed=$((total_passed + 1))
	else
		total_failed=$((total_failed + 1))
		echo "  !!! $name УПАЛ !!!"
	fi
	echo ""
}

run_test "WeaponConfig" "tests/test_weaponconfig.luau"
run_test "Gacha" "tests/test_gacha.luau"
run_test "Boss Phases" "tests/test_boss_phases.luau"
run_test "Combat Balance" "tests/test_combat_balance.luau"

echo "================================"
echo "  Файлов прошло: $total_passed"
echo "  Файлов упало:  $total_failed"
echo "================================"

if [ $total_failed -gt 0 ]; then
	exit 1
fi
