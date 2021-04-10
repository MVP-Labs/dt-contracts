pragma solidity 0.5.17;

// Copyright 2021 The dt-contracts Authors
// This file is part of the dt-contracts library.
//
// The dt-contracts library is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// The dt-contracts library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with the dt-contracts library. If not, see <http://www.gnu.org/licenses/>.

import "./RoleController.sol";
import "./DTFactory.sol";

/**
 * @title TaskMarket
 */
contract TaskMarket {
    uint256 private constant SUCCESS = 0;

    struct Task {
        address demander;
        string name;
        string desc;
        uint256 status;
        uint256[] jobIds;
    }

    struct Job {
        uint256 taskId;
        address solver;
        bytes32 cdt;
        uint256 status;
    }

    mapping(uint256 => Task) taskList;
    mapping(uint256 => Job) jobList;

    uint256 public taskNum = 0;
    uint256 public jobNum = 0;

    event TaskAdded(
        uint256 indexed _taskId,
        address _demander,
        string indexed _name,
        string _desc,
        uint256 indexed _code
    );

    event JobAdded(
        uint256 _taskId,
        uint256 indexed _jobId,
        address _solver,
        bytes32 indexed _cdt,
        uint256 indexed _code
    );

    RoleController private rc;
    DTFactory private df;

    /**
     * @dev constructor
     *      contract deployment
     * @param rcAddr refers to the RoleController address
     * @param dfAddr refers to the DTFactory address
     */
    constructor(address rcAddr, address dfAddr) public {
        rc = RoleController(rcAddr);
        df = DTFactory(dfAddr);
    }

    /**
     * @dev createTask
     *      adds a new task on-chain.
     * @param _name refers to the task name
     * @param _desc refers to the task description
     */
    function createTask(string memory _name, string memory _desc) public {
        uint256 taskId = 0;
        taskId = taskNum + 1;

        if (!rc.checkPermission(msg.sender, rc.MODIFY_TASK())) {
            emit TaskAdded(
                taskId,
                msg.sender,
                _name,
                _desc,
                rc.ERROR_NO_PERMISSION()
            );
            return;
        }

        taskNum++;
        taskList[taskId] = Task({
            demander: msg.sender,
            name: _name,
            desc: _desc,
            status: 1,
            jobIds: new uint256[](0)
        });

        emit TaskAdded(taskId, msg.sender, _name, _desc, SUCCESS);
    }

    /**
     * @dev addJob
     *      creates new computation job on-chain with the algorithm dt.
     * @param _cdt refers to the composable data token identifier
     * @param _taskId refers to the task id
     */
    function addJob(bytes32 _cdt, uint256 _taskId) public {
        uint256 jobId = 0;
        jobId = jobNum + 1;

        if (!rc.checkPermission(msg.sender, rc.MODIFY_TASK())) {
            emit JobAdded(
                _taskId,
                jobId,
                msg.sender,
                _cdt,
                rc.ERROR_NO_PERMISSION()
            );
            return;
        }

        if (taskList[_taskId].status != 1) {
            emit JobAdded(
                _taskId,
                jobId,
                msg.sender,
                _cdt,
                rc.ERROR_NO_PERMISSION()
            );
            return;
        }

        if (!df.isCDTAvailable(_cdt)) {
            emit JobAdded(
                _taskId,
                jobId,
                msg.sender,
                _cdt,
                rc.ERROR_NO_PERMISSION()
            );
            return;
        }

        if (df.getDTOwner(_cdt) != msg.sender) {
            emit JobAdded(
                _taskId,
                jobId,
                msg.sender,
                _cdt,
                rc.ERROR_NO_PERMISSION()
            );
            return;
        }

        jobNum++;
        jobList[jobId] = Job({
            taskId: _taskId,
            solver: msg.sender,
            cdt: _cdt,
            status: 1
        });

        taskList[_taskId].jobIds.push(jobId);

        emit JobAdded(_taskId, jobId, msg.sender, _cdt, SUCCESS);
    }

    /**
     * @dev getTask
     *      gets task status.
     * @param _taskId refers to the task id
     * @return Task struct.
     */
    function getTaskbyId(uint256 _taskId)
        public
        view
        returns (
            address demander,
            string memory name,
            string memory desc,
            uint256 status,
            uint256[] memory jobIds
        )
    {
        demander = taskList[_taskId].demander;
        name = taskList[_taskId].name;
        desc = taskList[_taskId].desc;
        status = taskList[_taskId].status;
        jobIds = taskList[_taskId].jobIds;
    }

    /**
     * @dev getJob
     *      gets job status.
     * @param _jobId refers to the job id
     * @return Job struct.
     */
    function getJobbyId(uint256 _jobId)
        public
        view
        returns (
            uint256 taskId,
            address solver,
            bytes32 cdt,
            uint256 status
        )
    {
        taskId = jobList[_jobId].taskId;
        solver = jobList[_jobId].solver;
        cdt = jobList[_jobId].cdt;
        status = jobList[_jobId].status;
    }

    /**
     * @dev getTaskNum
     *      gets the total task numbers.
     * @return uint256.
     */
    function getTaskNum()
        public
        view
        returns (
            uint256 totalTasks
        )
    {
        totalTasks = taskNum;
    }

    /**
     * @dev getJobNum
     *      gets the total job numbers.
     * @return uint256.
     */
    function getJobNum()
        public
        view
        returns (
            uint256 totalJobs
        )
    {
        totalJobs = jobNum;
    }
}
