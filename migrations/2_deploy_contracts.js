const RoleController = artifacts.require("RoleController");
const AssetProvider = artifacts.require("AssetProvider");
const OpTemplate = artifacts.require("OpTemplate");
const DTFactory = artifacts.require("DTFactory");
const TaskMarket = artifacts.require("TaskMarket");

module.exports = function(deployer) {
	deployer.deploy(RoleController).then(rc => {
		console.log('RoleController:', rc.address);
		return deployer.deploy(AssetProvider, rc.address).then(ap => {
			console.log('AssetProvider:', ap.address);
			return deployer.deploy(OpTemplate, rc.address).then(op => {
				console.log('OpTemplate:', op.address);
				return deployer.deploy(DTFactory, rc.address).then(df => {
					console.log('DTFactory:', df.address);
					return deployer.deploy(TaskMarket, rc.address, df.address).then(tm => {
						console.log('TaskMarket:', tm.address);
					})
				})
			})
		})
	});
};
