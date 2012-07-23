echo "Fixing issue with invalid date in gemspecs"
fix nodes_with_role:dea ssh:"sudo sed -i 's/ 00:00:00.000000000Z//' /usr/lib/ruby/gems/1.8/specifications/*"

echo "Installing Chef"
fix nodes_with_role:dea deploy_chef:gems=yes,ask=no

echo "Fixing issue with invalid date in gemspecs"
fix nodes_with_role:dea ssh:"sudo sed -i 's/ 00:00:00.000000000Z//' /usr/lib/ruby/gems/1.8/specifications/*"

echo "Running Chef convergence"
fix nodes_with_role:dea